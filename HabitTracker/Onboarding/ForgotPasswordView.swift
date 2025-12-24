//
//  ForgotPasswordView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 17/12/25.
//

import SwiftUI
enum ForgotPasswordField: Hashable{
    case email
}
struct ForgotPasswordView: View {

    @State private var userEmail: String = ""
    @State private var isLoading = false

    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @FocusState private var focusedField: ForgotPasswordField?

    var body: some View {
        VStack(spacing: 24) {

            // MARK: - Header
            VStack(spacing: 8) {
                Text("Forgot Password")
                    .font(.title2.weight(.semibold))

                Text("Enter your email and we’ll send you a reset link.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)

            // MARK: - Input
            VStack(spacing: 12) {
                TextField("Email address", text: $userEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.send)
                    .inputFieldStyle()

                // Inline error
                if let error = viewModel.authError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // MARK: - Button
            Button {
                resetPass()
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Send Reset Link")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(userEmail.isEmpty || isLoading)

            Spacer()
        }
        .padding()
        .onAppear {
            focusedField = .email
        }
        .alert("Email Sent",
               isPresented: $viewModel.resetPasswordSuccess) {
            Button("OK", role: .cancel) {
                userEmail = ""
            }
        } message: {
            Text("A password reset link will be sent shortly. Please check your spam folder if you don’t see it.")
        }
    }

    private func resetPass() {
        isLoading = true
        viewModel.resetPassword(email: userEmail)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
        }
    }
}


#Preview {
    ForgotPasswordView()
}
