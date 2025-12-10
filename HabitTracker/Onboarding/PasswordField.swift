//
//  PasswordField.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 23/08/25.
//


import SwiftUI
struct PasswordField: View {
    @Binding var text: String
    @State private var isSecure: Bool = true
    
    var placeholder: String
    
    var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(AppGradient.lightpurple)
            }
            .buttonStyle(.plain)
        }
    }
}



#Preview {
    PasswordField(text: .constant("hhh"), placeholder: "dew")
}


