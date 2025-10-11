

//
//  MonthyProgressBar.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 16/08/25.
//

import SwiftUI

struct MonthlyProgressBar: View {
    let habit: Habit
    let progress: CGFloat
    let startDate: Date
    let endDate: Date
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                    
                    // Progress
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    habit.habitColor,
                                    habit.habitColor.opacity(0.7)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text(startDate, formatter: DateFormatter.shortMonthDay)
                    .font(.caption)
                    .foregroundStyle(habit.habitColor.opacity(0.7))
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(habit.habitColor)
                
                Spacer()
                
                Text(endDate, formatter: DateFormatter.shortMonthDay)
                    .font(.caption)
                    .foregroundStyle(habit.habitColor.opacity(0.7))
            }
        }
    }
}

//#Preview {
//    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
//    testHabit.name = "Ritika"
//    testHabit.startDate = Date()
//    return MonthyProgressBar(habit: testHabit,progress: 0.5,startDate: Date(), endDate: Date())
//    
//}


