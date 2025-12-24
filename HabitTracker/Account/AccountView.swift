//
//  AccountView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 28/11/25.
//

import SwiftUI

struct AccountView: View {
    @State var showFeatureRequest = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .system


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
