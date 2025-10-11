//
//  AuthenticationService.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 29/08/25.
//
import Foundation
import CryptoKit

class AuthenticationService {
    static let shared = AuthenticationService()
    private init() {}
    
    func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePasswordStrength(_ password: String) -> String? {
        if password.count < 8 {
            return "Password must be at least 8 characters"
        }
        if !password.contains(where: { $0.isUppercase }) {
            return "Password must contain at least one uppercase letter"
        }
        if !password.contains(where: { $0.isNumber }) {
            return "Password must contain at least one number"
        }
        return nil
    }
}
