//
//  File.swift
//  
//
//  Created by Gabriel Sanchez Peraza on 05/07/24.
//

import Foundation

extension String {
    var isEmail: Bool {
        let emailPattern = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let regex = try? NSRegularExpression(pattern: emailPattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }
}
