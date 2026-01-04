//
//  ContentView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//
import SwiftUI
enum AppTheme: String {
    case system
    case light
    case dark
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @State private var sessionID = UUID()

    var body: some View {
        Group {
            if appState.isSessionLoading {
                // Splash / Loading Screen
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    ProgressView()
                }
            } else {
                if appState.isLoggedIn {
                    HomeView()
                        .id(sessionID)
                } else {
                    Onboarding()
                }
            }
        }
        .animation(.easeInOut, value: appState.isLoggedIn)
        .onChange(of: appState.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                sessionID = UUID()
            }
        }
        .alert("Session Expired", isPresented: $viewModel.showSessionExpiredAlert) {
            Button("OK", role: .cancel) {
                if viewModel.signOut() {
                    appState.isLoggedIn = false
                }
                viewModel.showSessionExpiredAlert = false
            }
        } message: {
            Text("Please log in again.")
        }
        .alert("Account Deleted", isPresented: $viewModel.showAccountDeletedAlert) {
             Button("OK", role: .destructive) {
                 if viewModel.signOut() {
                     appState.isLoggedIn = false
                 }
                 viewModel.showAccountDeletedAlert = false
             }
        } message: {
            Text("Your account has been deleted permanently.")
        }
    }
}


