//
//  AppHeader.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI
struct AppHeader: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Habit Tracker")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.primary)
            
            Text("Build better habits everyday.")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
}
#Preview {
    AppHeader()
}
