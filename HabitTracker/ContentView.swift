//
//  ContentView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        Group {
            if appState.isLoggedIn {
                HomeView()
            } else {
                Onboarding()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .animation(.easeInOut, value: appState.isLoggedIn)
    }
}

