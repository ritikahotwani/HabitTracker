

//
//  CloseStreakView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 18/08/25.
//

import SwiftUI

struct CloseStreakView: View {
    let bestStreak: Int
    let currentStreak: Int
    
    private var daysRemaining: Int {
        bestStreak - currentStreak + 1
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            Text("You are \(daysRemaining) days away from beating your best streak of \(bestStreak)! Keep it up!")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}
