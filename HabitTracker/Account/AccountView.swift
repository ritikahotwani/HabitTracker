//
//  AccountView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 28/11/25.
//

import SwiftUI

struct AccountView: View {
    @State var showFeatureRequest = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        VStack(spacing: 20) {
            ProfileView()

            List {
                Section("Preferences") {
                    appearanceRow(title: "Light Mode", isSelected: !isDarkMode) {
                        isDarkMode = false
                    }
                    appearanceRow(title: "Dark Mode", isSelected: isDarkMode) {
                        isDarkMode = true
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
