//
//  HabitName.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 14/08/25.
//
import SwiftUI

struct HabitName: View {
    @State var habit: Habit
    let calendar = Calendar.current
    let today = Date()
    var body: some View {
        HStack(spacing: 8) {
            CircularProgressView(
                progress: CGFloat((100.0 / Double(truncating: habit.noOfDays ?? 7) / 100.0)*Double(habit.completedDatesArray.count)),
                color: habit.habitColor
            )
            .frame(width: 24, height: 24)
            Text(habit.name ?? "")
                .lineLimit(2)
                .truncationMode(.tail)
                .background(
                    NavigationLink("", destination: HabitDetails(habit: habit))
                        .opacity(0)
                )
        }
    }
}


#Preview {
    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
    testHabit.name = "Ritika"
    testHabit.noOfDays = 4
    testHabit.completedDatesArray = [Date(), Date()-1,Date()-2]
    return HabitName(habit: testHabit)
}
