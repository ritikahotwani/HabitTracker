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
    @State private var isGoogleLoading = false
    @State private var presentFPView = false
    
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
//                    .onAppear{
//                        focusedField = .email
//                    }
                    .onSubmit {
                        focusedField = .password
                    }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section {
                PasswordField(text: $userPassword, placeholder: "Password")
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .inputFieldStyle()
                    .onSubmit {
                        signIn()
                    }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section {
                VStack(spacing: 12) {
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
                    
                    Button {
                        vibrate(style: .soft)
                        presentFPView = true
                    } label: {
                        Text("Forgot Password?")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack {
                        VStack { Divider() }
                        Text("Or")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                        VStack { Divider() }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section {
                GoogleSignInButton {
                    vibrate(style: .soft)
                    signInWithGoogle()
                }
            }
            .listRowBackground(Color.clear)
        }

        .listRowBackground(Color.clear)
        
        .scrollContentBackground(.hidden)
        .scrollContentBackground(.hidden)
        .listSectionSpacing(0)
        .alert("Sign In Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $presentFPView){
            ForgotPasswordView()
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
                    let name = self.viewModel.currentUser?.userName ?? "User"
                    NotificationManager.shared.showSignInSuccessNotification(for: name)
                } else {
                    // ❌ Show Firebase error message
                    self.errorMessage = viewModel.authError ?? "The email or password you entered is incorrect."
                    self.showError = true
                }
            }
        }
    }
    
    private func signInWithGoogle() {
        isGoogleLoading = true
        GoogleAuthHelper.signIn { result in
            switch result {
            case .success(let result):
                let (credential, name) = result
                viewModel.signInWithGoogle(credential: credential, googleName: name) { success in
                    DispatchQueue.main.async {
                        self.isGoogleLoading = false
                        if success {
                            self.appState.isLoggedIn = true
                            let userName = self.viewModel.currentUser?.userName ?? name ?? "User"
                            NotificationManager.shared.showSignInSuccessNotification(for: userName)
                        } else {
                            self.errorMessage = viewModel.authError ?? "Google Sign In Failed"
                            self.showError = true
                        }
                    }
                }
            case .failure(let error):
                self.isGoogleLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
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
            .padding(8)
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
