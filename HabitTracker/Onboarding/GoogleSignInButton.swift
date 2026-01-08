//
//  GoogleSignInButton.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 08/01/26.
//
import SwiftUI
import FirebaseAuth
struct GoogleSignInButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "globe") // Accessing SF Symbols as a fallback or placeholder
                    .font(.subheadline)
                Text("Sign in with Google")
                    .font(.headline)
            }
            .foregroundColor(.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}
