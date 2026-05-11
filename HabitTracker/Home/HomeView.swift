//
//  HomeView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 14/08/25.
//
import SwiftUI

struct HomeView: View {
    @State private var newHabit = ""
    @State private var dates: [Date] = []
    @State private var navigationPath = NavigationPath()
    @State private var stackResetID = UUID()
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack() {
                HeaderView()
                HabitList(dates: $dates)
            }
            .navigationTitle("Home")
            .navigationBarHidden(true)
            .navigationDestination(for: Habit.self) { habit in
                HabitDetails(habit: habit)
            }
            .onAppear {
                dates = viewModel.loadRecentDates()
            }
            .sheet(isPresented: $appState.showWidgetHabitPicker) {
                WidgetHabitPickerView()
            }
            .sheet(isPresented: $appState.showAddHabit) {
                AddHabit()
            }
        }
        .id(stackResetID)
        .onChange(of: appState.navigateToHome) { shouldNavigate in
            guard shouldNavigate else { return }
            stackResetID = UUID()
            appState.navigateToHome = false
        }
        .onChange(of: appState.deepLinkHabitID) { habitID in
            guard let id = habitID else { return }
            if let habit = viewModel.habits.first(where: { $0.id == id }) {
                navigationPath = NavigationPath()
                navigationPath.append(habit)
            }
            appState.deepLinkHabitID = nil
        }
    }
}

#Preview {
    HomeView()
}
