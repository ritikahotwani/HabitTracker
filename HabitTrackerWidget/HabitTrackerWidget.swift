import WidgetKit
import SwiftUI

@main
struct HabitTrackerWidget: Widget {
    let kind: String = "HabitTrackerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: HabitWidgetProvider()) { entry in
            HabitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Check")
        .description("Quickly mark your habit as done.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled() 
    }
}
