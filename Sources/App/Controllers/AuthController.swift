//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 04/04/24.
//

import Vapor
import JWT

struct AuthController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        
        auth.post("register", use: registerNewUser)
        auth.post("login", use: login)
        auth.get("send-otp", use: sendOtp)
        auth.post("validate-otp", use: validateOtp)
    }
    
    //POST auth/validate-otp
    func validateOtp(req: Request) async throws -> ModelResponse<String> {
        struct OtpRequest: Content {
            var subject: String
            var value: Int
            var token: String
        }
        
        let otpRequest: OtpRequest = try req.content.decode(OtpRequest.self)
        
        guard let otpModel: OTPModel = try await OTPModel.findBySubject(otpRequest.subject, on: req.db) else {
            throw AbortDefault.idNotExist(description: otpRequest.subject)
        }
        
        if otpRequest.value != otpModel.value || otpRequest.token != otpModel.valid_token || otpModel.type != OTPType.validate.rawValue {
            throw AbortDefault.unauthorized
        }
        let tokenManager = TokenManager()
        if !tokenManager.verifyToken(otpModel.valid_token).0 {
            //Unvalid token
            throw AbortDefault.otpExpired
        }
        
        guard let registerToken = tokenManager.createToken(subject: otpModel.subject, expiresIn: 8) else { throw AbortDefault.valueNilFromServer(key: "register_token") }
        
        otpModel.valid_token = registerToken
        otpModel.type = OTPType.register.rawValue
        try await otpModel.update(on: req.db)
        
        return .init(code: 200, description: "Success", body: registerToken)
    }
    
    //GET auth/send-otp
    func sendOtp(req: Request) async throws -> ModelResponse<String> {
        let otpSubject: String = try req.query.get(at: "subject")
        
        guard let token = TokenManager().createToken(subject: otpSubject, expiresIn: 600) else {
            throw AbortDefault.valueNilFromServer(key: "token")
        }
        guard let otpSubjectType: OTPSubjectType = .decodeByOTPSubject(otpSubject) else { throw AbortDefault.badRequest("EL valor de 'subject' no es valido") }
        
        let otpValue: Int = Int.random(in: 10000...99999)
        
        let newOtpModel: OTPModel = .init(value: otpValue, subject: otpSubject, subject_type: otpSubjectType.rawValue, valid_token: token, type: .validate)
        
        try await newOtpModel.validUniqueThenUpdateOrSave(on: req.db)
        
        sendOtpEmail(newOtpModel)
        
        return .init(code: 200, description: "Success", body: token)
    }
    
    private func sendOtpEmail(_ otp: OTPModel) {
        Task {
            // To do
        }
    }
    
    //POST auth/register
    func registerNewUser(req: Request) async throws -> ModelResponse<String> {
        let newUser: RegisterUserDTO = try req.content.decode(RegisterUserDTO.self)
        
        let validation = TokenManager().verifyToken(newUser.register_token)
        let registerOtp = try await OTPModel.findBySubject(validation.1, on: req.db)
    
        if  newUser.register_token != registerOtp?.valid_token || registerOtp?.type != OTPType.register.rawValue {
            throw AbortDefault.unauthorized
        }
        if !validation.0 {
            //Unvalid token
            throw Abort(.unauthorized, reason: "El token de registro ha caducado")
        }
        
        let token = try await req.db.transaction { db -> String in
            let commerce = Commerce(name: newUser.coommerce_name)
            try await commerce.save(on: db)
            
            guard let commerceID = commerce.id else { throw AbortDefault.valueNilFromServer(key: "commerce_id") }
            
            let passwordCryp = try Bcrypt.hash(newUser.password, cost: 10)
            let user = User(name: newUser.name, last_name: newUser.last_name, mother_name: newUser.mother_name, start_time: newUser.start_time, end_time: newUser.end_time, role: UserRole.admin.rawValue, number_phone: newUser.number_phone, email: newUser.email.lowercased(), password: passwordCryp, commerce: commerceID)
            
            let token = try await user.generateJWTToken(on: req)
            user.access_token = token
            try await user.save(on: db)
            
            return token;
        }
        
        return .init(code: 200, description: "Success", body: token)
    }
    
    //POST auth/login
    func login(req: Request) async throws -> ModelResponse<String> {
        let loginModel = try req.content.decode(LoginDTO.self)
                
        guard let user = try await User.find(email: loginModel.email.lowercased(), on: req.db) else { throw AbortDefault.unauthorized }
        if try !user.verify(password: loginModel.password) { throw AbortDefault.unauthorized }
        
        let newToken = try await user.generateJWTToken(on: req)
        user.access_token = newToken
        try await user.update(on: req.db)
        
        return .init(code: 200, description: "Success", body: newToken);
    }

}

