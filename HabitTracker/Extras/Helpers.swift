//
//  Helpers.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//
import SwiftUI
import Foundation
extension Color {
    func toData() -> Data? {
        return UIColor(self).encode()
    }
    
    static func fromData(_ data: Data) -> Color? {
        guard let uiColor = UIColor.decode(data: data) else { return nil }
        return Color(uiColor)
    }
}
extension UIColor {
    func encode() -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }

    static func decode(data: Data) -> UIColor? {
        try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
    }
}

extension UISegmentedControl {
    static func setAppearance() {
        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = UIColor.black
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    }
}

func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

func calculateStreaks(from datesCompleted: [Date]) -> (currentStreak: Int, bestStreak: Int) {
    let calendar = Calendar.current

    // Normalize dates to remove time component
    let normalizedDates = Set(datesCompleted.map {
        calendar.startOfDay(for: $0)
    })

    // Sort dates in descending order (most recent first)
    let sortedDates = normalizedDates.sorted(by: >)

    var currentStreak = 0
    var bestStreak = 0
    var streak = 0

    var previousDate: Date?

    for date in sortedDates {
        if let prev = previousDate {
            if let diff = calendar.dateComponents([.day], from: date, to: prev).day {
                if diff == 1 {
                    // Consecutive day
                    streak += 1
                } else if diff > 1 {
                    // Break in streak
                    streak = 1
                }
            }
        } else {
            streak = 1
        }

        bestStreak = max(bestStreak, streak)
        previousDate = date
    }

    // Calculate current streak from today
    var todayStreak = 0
    var currentDate = calendar.startOfDay(for: Date())

    while normalizedDates.contains(currentDate) {
        todayStreak += 1
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
        currentDate = yesterday
    }

    return (currentStreak: todayStreak, bestStreak: bestStreak)
}
extension Calendar {
    func isDate(_ date: Date, inCurrentWeekFor referenceDate: Date = Date()) -> Bool {
        guard let weekInterval = self.dateInterval(of: .weekOfYear, for: referenceDate) else { return false }
        return weekInterval.contains(date)
    }
}
