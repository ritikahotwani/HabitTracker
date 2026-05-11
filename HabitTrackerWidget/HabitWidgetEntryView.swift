import SwiftUI
import WidgetKit
import AppIntents
import UIKit

struct HabitWidgetEntryView: View {
    var entry: HabitEntry
    @Environment(\.widgetFamily) var family

    var habitColor: Color {
        guard let data = entry.habitColorData,
              let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            return .accentColor
        }
        return Color(uiColor)
    }

    var body: some View {
        Group {
            if !entry.isValid {
                emptyStateView
            } else if family == .systemMedium {
                mediumView
            } else {
                smallView
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
        // Only open the app when no habit is selected yet
        .widgetURL(
            entry.isValid
                ? URL(string: "habittracker://habit-details/\(entry.habitID?.uuidString ?? "")")
                : URL(string: "habittracker://select-habit")
        )
    }

    // MARK: - Small (155×155)
    var smallView: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header row
            HStack(alignment: .center, spacing: 4) {
                if !entry.habitIcon.isEmpty {
                    Text(entry.habitIcon)
                        .font(.system(size: 13))
                }
                Text(entry.habitName)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                Spacer(minLength: 4)

                if entry.streakCount > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.orange)
                        Text("\(entry.streakCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            Spacer()

            // Circle button — fixed size, centered
            HStack {
                Spacer()
                checkCircle(size: 60)
                Spacer()
            }

            Spacer()

            // Footer
            Text(entry.isCompleted ? "Done for today! 🔥" : "Tap to complete")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(entry.isCompleted ? habitColor : .secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(14)
    }

    // MARK: - Medium (329×155)
    var mediumView: some View {
        HStack(spacing: 16) {

            // Left: habit info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    if !entry.habitIcon.isEmpty {
                        Text(entry.habitIcon)
                            .font(.system(size: 26))
                    }
                    Text(entry.habitName)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                }

                if entry.streakCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.orange)
                        Text("\(entry.streakCount) day streak")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(entry.isCompleted ? "Done for today! 🔥" : "One small step today.")
                    .font(.system(size: 11))
                    .foregroundStyle(entry.isCompleted ? habitColor : .secondary)
            }

            Spacer()

            // Right: circle button
            checkCircle(size: 68)
        }
        .padding(16)
    }

    // MARK: - Reusable Circle Button
    @ViewBuilder
    func checkCircle(size: CGFloat) -> some View {
        Button(intent: ToggleHabitIntent(habitID: entry.habitID ?? UUID())) {
            ZStack {
                Circle()
                    .fill(entry.isCompleted
                          ? habitColor.opacity(0.15)
                          : Color(.tertiarySystemFill))
                Circle()
                    .strokeBorder(
                        entry.isCompleted ? habitColor : Color(.separator),
                        lineWidth: 2
                    )
                Image(systemName: entry.isCompleted ? "checkmark" : "circle")
                    .font(.system(size: size * 0.36, weight: .semibold))
                    .foregroundStyle(entry.isCompleted ? habitColor : Color(.tertiaryLabel))
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State
    var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text(entry.habitID == nil ? "Select a habit\nto track" : "Habit\nunavailable")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(14)
    }
}
