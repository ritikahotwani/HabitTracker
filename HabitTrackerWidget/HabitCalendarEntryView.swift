import SwiftUI
import WidgetKit
import UIKit

struct HabitCalendarEntryView: View {
    var entry: HabitEntry

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var habitColor: Color {
        guard let data = entry.habitColorData,
              let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            return .blue
        }
        return Color(uiColor)
    }

    var daysInCurrentMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: entry.date) else { return [] }
        var days: [Date] = []
        var current = monthInterval.start
        while current < monthInterval.end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return days
    }

    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: entry.date)
    }

    var body: some View {
        if !entry.isValid {
            emptyStateView
                .containerBackground(for: .widget) { Color(.systemBackground) }
                .widgetURL(URL(string: "habittracker://select-habit"))
        } else {
            calendarView
                .containerBackground(for: .widget) { Color(.systemBackground) }
                .widgetURL(URL(string: "habittracker://habit-details/\(entry.habitID?.uuidString ?? "")"))

        }
    }

    var emptyStateView: some View {
        VStack(spacing: 10) {
            Image(systemName: "plus.circle.dashed")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(entry.habitID == nil ? "Add a widget & select a habit\nto see your calendar" : "This habit is no longer available.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }

    var calendarView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: icon + habit name
            HStack(spacing: 6) {
                if !entry.habitIcon.isEmpty {
                    Text(entry.habitIcon)
                        .font(.title2)
                }
                Text(entry.habitName)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Spacer()

                // Month label
                Text(monthYearString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                // Weekday headers (single letter)
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(String(day.prefix(1)))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }

                // Leading offset for first weekday
                if let firstDate = daysInCurrentMonth.first {
                    let offset = (calendar.component(.weekday, from: firstDate) - calendar.firstWeekday + 7) % 7
                    ForEach(0..<offset, id: \.self) { _ in
                        Color.clear.frame(height: 24)
                    }
                }

                // Day cells
                ForEach(daysInCurrentMonth, id: \.self) { date in
                    let isCompleted = entry.completedDates.contains {
                        calendar.isDate($0, inSameDayAs: date)
                    }
                    let isFuture = calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
                    let isToday = calendar.isDateInToday(date)

                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(cellBackground(isCompleted: isCompleted, isFuture: isFuture))

                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 11, weight: isToday ? .bold : .medium, design: .monospaced))
                            .foregroundColor(cellTextColor(isCompleted: isCompleted, isFuture: isFuture, isToday: isToday))
                    }
                    .frame(maxWidth: .infinity, minHeight: 24)
                    .overlay {
                        if isToday && !isCompleted {
                            RoundedRectangle(cornerRadius: 4).strokeBorder(habitColor, lineWidth: 1.5)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 14)
        }
    }

    private func cellBackground(isCompleted: Bool, isFuture: Bool) -> Color {
        if isFuture { return Color.gray.opacity(0.08) }
        return isCompleted ? habitColor : habitColor.opacity(0.2)
    }

    private func cellTextColor(isCompleted: Bool, isFuture: Bool, isToday: Bool) -> Color {
        if isFuture { return .secondary.opacity(0.5) }
        if isCompleted { return contrastingTextColor(for: habitColor) }
        return .primary
    }

    private func contrastingTextColor(for color: Color) -> Color {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.5 ? .black : .white
    }
}
