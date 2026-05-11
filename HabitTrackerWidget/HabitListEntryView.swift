import SwiftUI
import WidgetKit
import UIKit

struct HabitListEntryView: View {
    var entry: HabitListEntry
    @Environment(\.widgetFamily) private var family

    // MARK: - Layout Constants

    private let circleSize: CGFloat = 16
    private let circleSpacing: CGFloat = 3
    private let rowVerticalPadding: CGFloat = 2

    /// Hard cap: a systemMedium widget (~155pt tall) comfortably fits ~4 rows at current sizing.
    /// Habits beyond this show a "+X more" label — WidgetKit does not support ScrollView.
    private var maxVisibleHabits: Int { 4 }

    // MARK: - Body

    var body: some View {
        switch entry.state {
        case .loggedOut:
            loggedOutView
                .containerBackground(for: .widget) { Color(.systemBackground) }
                .widgetURL(URL(string: "habittracker://login"))
        case .noHabits:
            noHabitsView
                .containerBackground(for: .widget) { Color(.systemBackground) }
                .widgetURL(URL(string: "habittracker://add-habit"))
        case .hasHabits:
            habitsListView
                .containerBackground(for: .widget) { Color(.systemBackground) }
                .widgetURL(URL(string: "habittracker://home"))
        }
    }

    // MARK: - Logged Out State

    private var loggedOutView: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("Log in to stay consistent")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("Tap to sign in")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(14)
    }

    // MARK: - No Habits State

    private var noHabitsView: some View {
        VStack(spacing: 10) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("Tap to add a new habit")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("Build tiny wins, every day")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(14)
    }

    // MARK: - Habits List

    private var habitsListView: some View {
        let visibleHabits = Array(entry.habits.prefix(maxVisibleHabits))
        let overflow = entry.habits.count - visibleHabits.count

        return VStack(alignment: .leading, spacing: 0) {
            // Column headers: blank space for icon+name column, then one label per day
            dayHeaderRow
                .padding(.bottom, 4)

            Rectangle()
                .fill(Color(.separator).opacity(0.4))
                .frame(height: 0.5)
                .padding(.bottom, 4)

            // One row per habit — height grows with each row, no bottom Spacer
            ForEach(visibleHabits) { habit in
                habitRow(for: habit)
                    .padding(.vertical, rowVerticalPadding)
            }

            // Overflow indicator when habits exceed the hard cap
            if overflow > 0 {
                Text("+\(overflow) more habit\(overflow == 1 ? "" : "s")")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 3)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Day Header Row

    private var dayHeaderRow: some View {
        HStack(spacing: 0) {
            // Phantom spacer that matches the width of the habit name column
            Spacer()

            // Day initials aligned over their corresponding circles
            HStack(spacing: circleSpacing) {
                ForEach(Array(entry.weekdayLabels.enumerated()), id: \.offset) { _, label in
                    Text(label.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: circleSize, alignment: .center)
                }
            }
        }
        .frame(height: 12)
    }

    // MARK: - Habit Row

    private func habitRow(for habit: HabitRowData) -> some View {
        HStack(spacing: 0) {
            // Icon + Name
            HStack(spacing: 4) {
                if !habit.icon.isEmpty {
                    Text(habit.icon)
                        .font(.system(size: 12))
                }
                Text(habit.name)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 7 completion circles — one per day of the week
            HStack(spacing: circleSpacing) {
                ForEach(Array(entry.weekDays.enumerated()), id: \.offset) { _, day in
                    completionDot(for: habit, on: day)
                }
            }
        }
    }

    // MARK: - Completion Dot

    private func completionDot(for habit: HabitRowData, on day: Date) -> some View {
        let isCompleted = habit.isCompleted(on: day)
        let isFuture = Calendar.current.startOfDay(for: day) > Calendar.current.startOfDay(for: Date())
        let color = decodedColor(from: habit.habitColorData)

        return Circle()
            .fill(dotFillColor(isCompleted: isCompleted, isFuture: isFuture, habitColor: color))
            .frame(width: circleSize, height: circleSize)
            .overlay {
                // Subtle stroke on past/today unfilled circles to improve readability
                if !isCompleted && !isFuture {
                    Circle()
                        .strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5)
                }
            }
    }

    // MARK: - Helpers

    private func dotFillColor(isCompleted: Bool, isFuture: Bool, habitColor: Color) -> Color {
        if isCompleted { return habitColor }
        if isFuture    { return Color.gray.opacity(0.07) }
        return Color.gray.opacity(0.14)
    }

    /// Decodes a UIColor-archived Data back into a SwiftUI Color.
    /// Falls back to the app's default accent purple if decoding fails.
    private func decodedColor(from data: Data?) -> Color {
        guard let data,
              let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            return Color(red: 0.56, green: 0.44, blue: 0.87) // AppGradient.purple
        }
        return Color(uiColor)
    }
}
