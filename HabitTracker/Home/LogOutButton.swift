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
    var body: some View {
        Button {
            showLogoutAlert = true
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.title2)
                .foregroundColor(.gray)
        }
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

