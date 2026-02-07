import SwiftUI
import WidgetKit
import AppIntents

struct HabitWidgetEntryView: View {
    var entry: HabitEntry
    
    var body: some View {
        VStack {
            if !entry.isValid {
                emptyStateView
            } else {
                activeHabitView
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.dashed")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(entry.habitID == nil ? "Create a habit\nto start your streak 🌱" : "This habit is\nno longer available.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
    
    var activeHabitView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Name and Streak
            HStack(alignment: .top) {
                Text(entry.habitName)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if entry.streakCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption2)
                        Text("\(entry.streakCount)")
                            .font(.caption.bold())
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.bottom, 4)
            
            Spacer()
            
            // Large Interaction Area
            Button(intent: ToggleHabitIntent(habitID: entry.habitID ?? UUID())) {
                ZStack {
                    if entry.isCompleted {
                        // Completed State
                        Circle()
                            .fill(Color.green.opacity(0.15))
                        
                        Image(systemName: "checkmark.circle.fill")
                           .font(.system(size: 40))
                           .foregroundColor(.green)
                            
                    } else {
                        // Incomplete State
                        Circle()
                            .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
                            .background(Circle().fill(Color.accentColor.opacity(0.05)))
                        
                        Image(systemName: "circle")
                            .font(.system(size: 40))
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Circle()) // Ensures touch target is the circle
            
            Spacer()
            
            // Footer: Motivational Copy
            HStack {
                Spacer()
                Text(motivationalText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(entry.isCompleted ? .green : .secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
    }
    
    var motivationalText: String {
        if entry.isCompleted {
            return "Done for today! 🔥"
        } else {
            return "One small step today."
        }
    }
}
