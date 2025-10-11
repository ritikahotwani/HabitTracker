//
//  HabitStartView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 14/08/25.
//

import SwiftUI

struct HabitStartView: View {
    let habit: Habit
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.4))
            
            if let startDate = habit.startDate {
                Text("You have started this habit from \(startDate, formatter: DateFormatter.medium).")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}


#Preview {
    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
    testHabit.name = "Ritika"
    testHabit.startDate = Date() - 3
    return HabitStartView(habit: testHabit)
    
}
