//
//  Enums.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//
import Foundation
import SwiftUI

enum OnboardingOption:String,CaseIterable {
    case signIn = "Sign In"
    case signUp = "Sign Up"
    
       var title: String {
           switch self {
           case .signIn: "Sign In"
           case .signUp: "Sign Up"
           }
       }
}
enum HabitFrequency: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case Daily, Weekly, Monthly
    
}

enum PasswordStrength {
    case weak, medium, strong
    
    var bars: Int {
        switch self {
        case .weak: return 1
        case .medium: return 2
        case .strong: return 3
        }
    }
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }
    
    var text: String {
        switch self {
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }
}


enum Months: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
    var number: Int {
        switch self {
        case .Jan: return 1
        case .Feb: return 2
        case .Mar: return 3
        case .Apr: return 4
        case .May: return 5
        case .Jun: return 6
        case .Jul: return 7
        case .Aug: return 8
        case .Sep: return 9
        case .Oct: return 10
        case .Nov: return 11
        case .Dec: return 12
        }
    }
}
