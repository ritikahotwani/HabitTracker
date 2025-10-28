//
//  LogOutButton.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 23/08/25.
//
import SwiftUI

struct LogOutButton: View {
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @EnvironmentObject var appState: AppState
    @State private var showLogoutAlert = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Button {
            showLogoutAlert = true
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray)
                .frame(width: 32, height: 32)
                .padding(8)
                .background(
                    Circle()
                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.7))
                        .shadow(radius: 3)
                )
        }
        .padding(.horizontal, 4)
        .alert("Are you sure you want to log out?", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                if viewModel.signOut() {
                    appState.isLoggedIn = false
                }
            }
        }
    }
}

#Preview {
    LogOutButton()
}

