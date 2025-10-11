//import SwiftUI
//struct HabistDetails: View {
//    @ObservedObject var habit: Habit
//    @Environment(\.dismiss) private var dismiss
//    
//    @State private var currentStreak: Int = 0
//    @State private var bestStreak: Int = 0
//    
//    private let completedDates: [Date]
//    
//    init(habit: Habit) {
//        self.habit = habit
//        self.completedDates = habit.completedDatesArray
//    }
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 16) {
//                statsCardsSection
//                
//                if shouldShowCloseStreakView {
//                    CloseStreakView(bestStreak: bestStreak, currentStreak: currentStreak)
//                        .padding(.horizontal)
//                }
//                
//                CalendarHeatMap(habit: habit)
//                MonthlyProgress(habit: habit)
//                WeeklyProgress(habit: habit)
//                HabitStartView(habit: habit)
//                    .padding(.bottom)
//            }
//            .padding(.top, 8)
//        }
//        .ignoresSafeArea(edges: .bottom)
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                backButton
//            }
//            ToolbarItem(placement: .principal) {
//                HabitHeaderView(habit: habit)
//            }
//        }
//        .task {
//            calculateStreaks()
//        }
//    }
//    
//    // MARK: - Subviews
//    
//    private var statsCardsSection: some View {
//        HStack(spacing: 12) {
//            CountCard(
//                habit: habit,
//                heading: "Total Days",
//                count: completedDates.count
//            )
//            
//            CountCard(
//                habit: habit,
//                heading: "Current Streak",
//                count: currentStreak
//            )
//            
//            CountCard(
//                habit: habit,
//                heading: "Best Streak",
//                count: bestStreak
//            )
//        }
//        .padding(.horizontal)
//    }
//    
//    private var backButton: some View {
//        Button(action: { dismiss() }) {
//            Image(systemName: "chevron.left")
//                .foregroundColor(.primary)
//        }
//    }
//    
//    // MARK: - Computed Properties
//    
//    private var shouldShowCloseStreakView: Bool {
//        bestStreak > 0 && (bestStreak - 7)...(bestStreak - 1) ~= currentStreak
//    }
//    
//    // MARK: - Methods
//    
//    private func calculateStreaks() {
//        let streaks = HabitTracker.calculateStreaks(from: completedDates)
//        currentStreak = streaks.currentStreak
//        bestStreak = streaks.bestStreak
//    }
//}
