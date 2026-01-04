//
//  AccountView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 28/11/25.
//

import SwiftUI

struct AccountView: View {
    @State var showFeatureRequest = false
    @State private var showDeleteAlert = false
    @State private var showDeleteErrorAlert = false

    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            ProfileView()

            List {
                Section("Appearance") {
                    appearanceRow(title: "System", isSelected: appTheme == .system) {
                        appTheme = .system
                    }

                    appearanceRow(title: "Light", isSelected: appTheme == .light) {
                        appTheme = .light
                    }

                    appearanceRow(title: "Dark", isSelected: appTheme == .dark) {
                        appTheme = .dark
                    }
                }


                Section("Feel like something is missing?") {
                    Button {
                        showFeatureRequest = true
                    } label: {
                        Text("Request a feature")
                    }
                    .padding(.horizontal, 4)
                }

                Section("Account") {
                    LogOutButton()
                }
                // MARK: - Danger Zone
                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Text("Delete Account")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fontWeight(.medium)
                    }
                }
                
                Section {
                    // Empty section for spacing
                } footer: {
                    VStack(spacing: 4) {
                        Text("Data is stored locally on this device. Deleting the app will remove your habits.")
                            .multilineTextAlignment(.center)
                        
                        Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .padding(.top, 20)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)

        .navigationDestination(isPresented: $showFeatureRequest) {
            FeatureRequestView()
        }
        // MARK: - Delete Alert
               .alert("Delete Account?", isPresented: $showDeleteAlert) {
                   Button("Delete", role: .destructive) {
                       viewModel.deleteAccount { success in
                              if success {
                                  appState.isLoggedIn = false
                              }
                          }
                   }
                   Button("Cancel", role: .cancel) {
                       // auto dismiss
                   }
               } message:
                   {
                                  Text("This will permanently delete your account and all habits stored on this device. This cannot be undone.")
                              }
               
               .onChange(of: viewModel.authError) { error in
                   if error != nil {
                       showDeleteErrorAlert = true
                   }
               }
               .alert("Unable to Delete Account",
                      isPresented: $showDeleteErrorAlert) {

                   Button("OK", role: .cancel) {}

               } message: {
                   Text("For security reasons, please log in again to delete your account.")
               }


    }
}



    private func appearanceRow(title: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }



#Preview {
    AccountView()
}
