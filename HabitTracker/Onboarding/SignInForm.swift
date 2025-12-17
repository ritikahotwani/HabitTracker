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
                    .inputFieldStyle()
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
                    .inputFieldStyle()
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

                Button(action: signIn) {
                        Text("Forgot Password?")
                            .frame(maxWidth: .infinity)
                    
                }
                .buttonStyle(.plain)
            
            
        }
        .listRowBackground(Color.clear)
        
        .scrollContentBackground(.hidden)
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
        
        let password = userPassword
        
        // ✅ Call the new Firebase-based sign-in method
        viewModel.signInUser(email: email, password: password) { success in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    // ✅ Update app state on success
                    self.appState.isLoggedIn = true
                    NotificationManager.shared.showSignInSuccessNotification(for: self.userEmail)
                } else {
                    // ❌ Show Firebase error message
                    self.errorMessage = viewModel.authError ?? "The email or password you entered is incorrect."
                    self.showError = true
                }
            }
        }
    }
    
}

#Preview {
    SignInForm()
}



struct InputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

extension View {
    func inputFieldStyle() -> some View {
        self.modifier(InputFieldStyle())
    }
}
