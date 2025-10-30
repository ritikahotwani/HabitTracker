//
//  CountCard.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI

struct CountCard: View {
    let habit: Habit
    let heading: String
    let count: Int
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 10) {
            Text(heading.uppercased())
                .font(.caption2)
                .fontWeight(.medium)
                .kerning(1)
                .foregroundColor(.secondary)

            Text("\(count)")
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(cardBackground)
                .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(habit.habitColor.opacity(0.25), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(habit.habitColor.opacity(0.15))
                .frame(width: 10, height: 10)
                .padding(10)
        }
        .padding(.horizontal, 4)
        .animation(.spring(duration: 0.25), value: count)
    }
    
    private var cardBackground: Color {
        colorScheme == .dark
        ? Color(.secondarySystemBackground).opacity(0.6)
        : Color(.systemBackground)
    }
    
    private var shadowColor: Color {
        colorScheme == .dark
        ? Color.black.opacity(0.3)
        : Color.black.opacity(0.06)
    }
}


//#Preview {
//    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
//    testHabit.name = "Ritika"
//    return CountCard(habit: testHabit, heading: "Best Streak", image: "trophy", sentence: "Your personal record!",count: 10)
//    
//}
