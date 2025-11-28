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
        Button {
            
                isDarkMode.toggle()

        } label: {
            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isDarkMode ? .yellow : .orange)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.6))
                )
        }
        .buttonStyle(.plain)     
    }
}


#Preview {
    ThemeToggleButton()
}
