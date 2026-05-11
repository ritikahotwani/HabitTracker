import WidgetKit
import SwiftUI

struct HabitListWidget: Widget {
    let kind: String = "HabitListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitListWidgetProvider()) { entry in
            HabitListEntryView(entry: entry)
        }
        .configurationDisplayName("Weekly Habit Overview")
        .description("See all your habits and this week's completion at a glance.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}
