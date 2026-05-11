import SwiftUI
import WidgetKit

struct WidgetHabitPickerView: View {
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @Environment(\.dismiss) var dismiss

    private let suite = "group.com.ritikahotwani.HabitTracker"
    private let key = "widget_selected_habit_id"

    @State private var selectedID: UUID? = {
        guard let s = UserDefaults(suiteName: "group.com.ritikahotwani.HabitTracker")?
            .string(forKey: "widget_selected_habit_id") else { return nil }
        return UUID(uuidString: s)
    }()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.habits.isEmpty {
                    ContentUnavailableView(
                        "No Habits Yet",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Add a habit in the app first.")
                    )
                } else {
                    List(viewModel.habits) { habit in
                        Button {
                            select(habit)
                        } label: {
                            HStack(spacing: 14) {
                                if let icon = habit.icon, !icon.isEmpty {
                                    Text(icon)
                                        .font(.title2)
                                        .frame(width: 36)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(habit.name ?? "")
                                        .foregroundStyle(.primary)
                                        .font(.body)
                                    if let freq = habit.frequency {
                                        Text(freq)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                if habit.id == selectedID {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(habit.habitColor)
                                        .font(.title3)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Choose Habit for Widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func select(_ habit: Habit) {
        guard let id = habit.id else { return }
        UserDefaults(suiteName: suite)?.set(id.uuidString, forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
        selectedID = id
        dismiss()
    }
}
