//
//  HabitDetails.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI
import Charts

struct HabitDetails: View {
    @ObservedObject var habit: Habit
    @Environment(\.dismiss) var dismiss
    
    @State var currentStreak: Int = 0
    @State var bestStreak: Int = 0
    
    private let completedDates: [Date]
    
    init(habit: Habit) {
        self.habit = habit
        self.completedDates = habit.completedDatesArray
    }
    
    var body: some View {
        
            ScrollView {
                VStack(spacing: 16) {
                    statsCardsSection
                    
                    if shouldShowCloseStreakView {
                        CloseStreakView(bestStreak: bestStreak, currentStreak: currentStreak)
                            .padding(.horizontal)
                    }
                    
                    CalendarHeatMap(habit: habit)
                    MonthlyProgress(habit: habit)
                    WeeklyProgress(habit: habit)
                    HabitStartView(habit: habit)
                        .padding(.bottom)
                }
                .padding(.top, 8)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarBackButtonHidden(true)
        
        
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
            ToolbarItem(placement: .principal) {
                HabitHeaderView(habit: habit)
            }
        }
        .task {
            calculateStreaks()
        }
    }
    private var statsCardsSection: some View {
        HStack(spacing: 12) {
            CountCard(
                habit: habit,
                heading: "Total Days",
                count: completedDates.count
            )
            
            CountCard(
                habit: habit,
                heading: "Current Streak",
                count: currentStreak
            )
            
            CountCard(
                habit: habit,
                heading: "Best Streak",
                count: bestStreak
            )
        }
        .padding(.horizontal)
    }
    
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Computed Properties
    
    private var shouldShowCloseStreakView: Bool {
        bestStreak > 0 && (bestStreak - 7)...(bestStreak - 1) ~= currentStreak
    }
    
    // MARK: - Methods
    
    private func calculateStreaks() {
        let streaks = HabitTracker.calculateStreaks(from: completedDates)
        currentStreak = streaks.currentStreak
        bestStreak = streaks.bestStreak
    }
}


#Preview {
    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
    testHabit.name = "Ritika"
    
    let calendar = Calendar.current
    let today = Date()
    testHabit.startDate = calendar.date(byAdding: .day, value: -7, to: today)!
    testHabit.completedDatesArray  = [
        calendar.date(byAdding: .day, value: -7, to: today)!, // 7 days ago
        calendar.date(byAdding: .day, value: -6, to: today)!,
        calendar.date(byAdding: .day, value: -5, to: today)!,
        calendar.date(byAdding: .day, value: -3, to: today)!,
        calendar.date(byAdding: .day, value: -1, to: today)!,
        today,
        
        calendar.date(byAdding: .day, value: -14, to: today)!, // 2 weeks ago
        calendar.date(byAdding: .day, value: -13, to: today)!,
        calendar.date(byAdding: .day, value: -11, to: today)!,
        
        calendar.date(byAdding: .day, value: -20, to: today)!, // 3 weeks ago
        calendar.date(byAdding: .day, value: -19, to: today)!,
        
        calendar.date(byAdding: .day, value: -28, to: today)!,
        
        calendar.date(byAdding: .day, value: -56, to: today)!,
        
        calendar.date(byAdding: .day, value: -32, to: today)!,
        calendar.date(byAdding: .day, value: -100, to: today)!
        // 4 weeks ago
    ]
    
    return HabitDetails(habit: testHabit)
}








#Preview {
    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
    testHabit.name = "Ritika"
  return  HabitHeaderView(habit: testHabit)
}





