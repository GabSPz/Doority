//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 05/07/24.
//

import CryptoKit
import Foundation

struct TokenManager {
    private var secretKey: Data? {
        Constants.tokenManagerKey?.data(using: .utf8)
    }
    
    func createToken(subject: String, expiresIn secondsInterval: TimeInterval = 3600) -> String? {
        
        guard let secretKey = secretKey else { return nil }
        
        let payload = [
            "subject": subject,
            "exp": Date().addingTimeInterval(secondsInterval).timeIntervalSince1970
        ] as [String : Any]
        
        guard let payloadData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            return nil
        }
        
        let payloadBase64 = payloadData.base64EncodedString()
        let signature = HMAC<SHA256>.authenticationCode(for: payloadData, using: SymmetricKey(data: secretKey))
        let signatureHex = Data(signature).map { String(format: "%02hhx", $0) }.joined()
        
        return "\(payloadBase64).\(signatureHex)"
    }
    
    func verifyToken(_ token: String) -> (Bool, String?) {
        guard let secretKey = secretKey else { return (false, nil) }

        let components = token.split(separator: ".")
        guard components.count == 2,
              let payloadBase64 = components.first,
              let signatureHex = components.last,
              let payloadData = Data(base64Encoded: String(payloadBase64)),
              let signatureData = Data(hexString: String(signatureHex)) else {
            return (false, nil)
        }
        
        let isValidSignature = HMAC<SHA256>.isValidAuthenticationCode(signatureData, authenticating: payloadData, using: SymmetricKey(data: secretKey))
        
        guard isValidSignature,
              let payload = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
              let expTimestamp = payload["exp"] as? TimeInterval, let subject = payload["subject"] as? String,
              Date().timeIntervalSince1970 < expTimestamp else {
            return (false, nil)
        }
        
        return (true, subject)
    }
}

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}
