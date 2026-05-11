import WidgetKit
import SwiftUI

struct HabitCalendarWidget: Widget {
    let kind: String = "HabitCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
            HabitCalendarEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Calendar")
        .description("View your monthly habit completion calendar.")
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabled()
    }
}
