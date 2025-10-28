//
//  HeaderView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//
import SwiftUI

import SwiftUI

struct HeaderView: View {


    var body: some View {
        HStack {
            Text("Habit Tracker")
                .font(.system(size: 30, weight: .bold, design: .default))

            Spacer()
            ThemeToggleButton()
            AddButton()
            LogOutButton()
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
    }
}



#Preview {
    HeaderView()
}
