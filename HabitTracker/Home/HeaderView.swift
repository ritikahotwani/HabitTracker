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
            VStack(alignment: .leading, spacing: 2) {
                Text("Tiny Wins")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .tracking(0.4)
                    .foregroundStyle(AppGradient.purple)

                Text("Small habits. Big change.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
            
//            ThemeToggleButton()
            AddButton()
            ProfileButton()
//            LogOutButton()
        }
        .padding(.vertical)
        .padding(.horizontal)
    }
}



#Preview {
    HeaderView()
}
