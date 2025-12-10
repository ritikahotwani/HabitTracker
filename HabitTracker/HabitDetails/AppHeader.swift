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
            Text("Tiny Wins")
                .font(.largeTitle.bold())
                .foregroundStyle(AppGradient.purple)
            
            Text("Build better habits everyday.")
                .font(.headline)
                .foregroundStyle(AppGradient.purpleMauve)
        }
        .padding(.horizontal)
    }
}
#Preview {
    AppHeader()
}
