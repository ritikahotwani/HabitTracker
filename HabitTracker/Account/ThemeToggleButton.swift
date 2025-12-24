//
//  ThemeToggleButton.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 28/10/25.
//

import SwiftUI

struct ThemeToggleButton: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @Environment(\.colorScheme) var systemScheme

    private var isDark: Bool {
        switch appTheme {
        case .dark:
            return true
        case .light:
            return false
        case .system:
            return systemScheme == .dark
        }
    }

    var body: some View {
        Button {
            appTheme = isDark ? .light : .dark
        } label: {
            Image(systemName: isDark ? "moon.fill" : "sun.max.fill")
                .foregroundColor(isDark ? .yellow : .orange)
        }
        .buttonStyle(.plain)
    }
}



#Preview {
    ThemeToggleButton()
}
