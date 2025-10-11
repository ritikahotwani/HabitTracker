//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI
import CoreData

@main
struct HabitTrackerApp: App {
    @StateObject var appState = AppState()
    @StateObject var viewModel = HabitTrackerViewModel() 

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(viewModel)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}












