//
//  SignUpForm.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 23/08/25.
//

import SwiftUI
enum Field: Hashable {
    case name, email, password, confirmPassword
}
struct SignUpForm: View {
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var userPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showError = false
    @State private var errorMessage: String = ""
    @State private var isLoading = false
    
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @EnvironmentObject var appState:AppState
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        Form {
            Section {
                TextField("Full Name", text: $userName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .inputFieldStyle()
                    .onAppear{
                        focusedField = .name
                    }
                    .onSubmit { focusedField = .email }
                
            }
            
            Section {
                TextField("Email", text: $userEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .inputFieldStyle()
                    .onSubmit { focusedField = .password }
            }
            
            Section {
                PasswordField(text: $userPassword, placeholder: "Password")
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .inputFieldStyle()
                    .onSubmit { focusedField = .confirmPassword }
                

            } footer: {
                Text("Must be at least 8 characters with uppercase and number")
                    .font(.caption)
            }
            
            Section {
                PasswordField(text: $confirmPassword, placeholder: "Confirm Password")
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.go)
                    .inputFieldStyle()
                    .onSubmit { signUp() }
                
                // Password match indicator
                if !confirmPassword.isEmpty {
                    HStack {
                        Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(passwordsMatch ? .green : .red)
                        Text(passwordsMatch ? "Passwords match" : "Passwords don't match")
                            .font(.caption)
                            .foregroundColor(passwordsMatch ? .green : .red)
                    }
                }
            }
            
            Button(action: signUp) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isFormInvalid || isLoading)
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .listSectionSpacing(5)
        .alert("Sign Up Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    private var passwordsMatch: Bool {
        !userPassword.isEmpty && userPassword == confirmPassword
    }
    
    private var isFormInvalid: Bool {
        userName.trimmingCharacters(in: .whitespaces).isEmpty ||
        userEmail.trimmingCharacters(in: .whitespaces).isEmpty ||
        userPassword.isEmpty ||
        confirmPassword.isEmpty ||
        !passwordsMatch
    }
    
    private func signUp() {
        let name = userName.trimmingCharacters(in: .whitespaces)
        let email = userEmail.trimmingCharacters(in: .whitespaces)
        
        // Validate email
        guard AuthenticationService.shared.isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        // Validate password strength
        if let error = AuthenticationService.shared.validatePasswordStrength(userPassword) {
            errorMessage = error
            showError = true
            return
        }
        
        // Check passwords match
        guard userPassword == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        
        isLoading = true
        focusedField = nil // Dismiss keyboard
        
        // 🚫 DO NOT hash password for Firebase
        let password = userPassword
        
        // ✅ Call Firebase sign up (async)
        viewModel.signUpUser(email: email, password: password, name: name) { success in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    self.appState.isLoggedIn = true
                } else {
                    self.errorMessage = self.viewModel.authError ?? "Failed to create your account."
                    self.showError = true
                }
            }
        }
    }

}

#Preview {
    SignUpForm()
}
