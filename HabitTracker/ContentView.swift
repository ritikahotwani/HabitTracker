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

    var body: some View {
        Group {
            if appState.isLoggedIn {
                HomeView()
            } else {
                Onboarding()
            }
        }
        .animation(.easeInOut, value: appState.isLoggedIn)
        .alert(
            "Session Ended",
            isPresented: Binding(
                get: { appState.sessionMessage != nil },
                set: { _ in appState.sessionMessage = nil }
            )
        ) {
            Button("OK", role: .cancel) {
                appState.sessionMessage = nil
            }
        } message: {
            Text(appState.sessionMessage ?? "")
        }
    }
}


