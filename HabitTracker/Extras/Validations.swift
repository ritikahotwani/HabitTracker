//
//  Validations.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 27/08/25.
//
import Foundation

extension HabitTrackerViewModel{
    

func validateSignUp(name: String, email: String, password: String, confirmPassword: String) -> String? {
    if name.trimmingCharacters(in: .whitespaces).isEmpty {
        return "Full name cannot be empty."
    }
    if !isValidEmail(email) {
        return "Please enter a valid email."
    }
    if password.count < 6 {
        return "Password must be at least 6 characters."
    }
    if password != confirmPassword {
        return "Passwords do not match."
    }
    return nil // ✅ No errors
}

private func isValidEmail(_ email: String) -> Bool {
    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
}
}
