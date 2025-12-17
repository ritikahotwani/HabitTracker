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
    @State private var userPassword: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @EnvironmentObject var appState: AppState
    
    @FocusState private var focusedField: ForgotPasswordField?
    var body: some View {
        VStack{
            Text("Forgot Password")
                .font(.headline)
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
//                        .onsubmit{
//                            
//                        }
                    
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
