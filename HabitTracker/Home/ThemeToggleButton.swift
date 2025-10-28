//
//  ThemeToggleButton.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 28/10/25.
//

import SwiftUI

struct ThemeToggleButton: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                isDarkMode.toggle()
            }
        }) {
            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isDarkMode ? .yellow : .orange)
                .frame(width: 30, height: 30)
                .padding(8)
                .background(
                    Circle()
                        .fill(isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.7))
                        .shadow(radius: 3)
                )
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    ThemeToggleButton()
}
