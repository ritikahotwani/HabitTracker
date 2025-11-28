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
            Text("Tiny Wins")
                .font(.system(size: 35, weight: .bold))
                .foregroundStyle(AppGradient.purple)
            Spacer()
                ProfileButton()
//            ThemeToggleButton()
            AddButton()
//            LogOutButton()
        }
        .padding(.vertical)
        .padding(.horizontal)
    }
}



#Preview {
    HeaderView()
}
