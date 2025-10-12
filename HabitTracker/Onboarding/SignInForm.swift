//
//  SignInForm.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 23/08/25.
//
import SwiftUI
enum SignInField: Hashable {
    case email, password
}
struct SignInForm: View {
    
    @State private var userEmail: String = ""
       @State private var userPassword: String = ""
       @State private var showError = false
       @State private var errorMessage = ""
       @State private var isLoading = false
    
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @EnvironmentObject var appState: AppState
    
    @FocusState private var focusedField: SignInField?
    
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $userEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onAppear{
                        focusedField = .email
                    }
                    .onSubmit {
                        focusedField = .password
                    }
            }
            
            Section {
                PasswordField(text: $userPassword, placeholder: "Password")
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        signIn()
                    }
            }
            
            Button(action: signIn) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isFormInvalid || isLoading)
            .listRowBackground(Color.clear)
        }
        .listSectionSpacing(10)
        .alert("Sign In Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    private var isFormInvalid: Bool {
        userEmail.trimmingCharacters(in: .whitespaces).isEmpty ||
        userPassword.isEmpty
    }
    
    private func signIn() {
        // Trim whitespace
        let email = userEmail.trimmingCharacters(in: .whitespaces)
        
        // Validate email format
        guard AuthenticationService.shared.isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        isLoading = true
        focusedField = nil
        
        // Hash password before sending
        let hashedPassword = AuthenticationService.shared.hashPassword(userPassword)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if viewModel.signInUser(email: email, password: hashedPassword) {
                appState.isLoggedIn = true
                NotificationManager.shared.showSignInSuccessNotification(for: userEmail)
            } else {
                errorMessage = "The email or password you entered is incorrect."
                showError = true
            }
            isLoading = false
        }
    }
}

#Preview {
    SignInForm()
}
