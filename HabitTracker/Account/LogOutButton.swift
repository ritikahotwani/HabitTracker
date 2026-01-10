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
    @State private var showAlert = false

    var body: some View {
        Button(role: .destructive) {
            vibrate(style: .medium)
            showAlert = true
        } label: {
            Text("Log Out")
                .font(.system(size: 16))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .alert("Are you sure you want to log out?", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                vibrate(style: .rigid)
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

