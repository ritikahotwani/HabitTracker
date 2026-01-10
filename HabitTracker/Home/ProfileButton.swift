//
//  ProfileButton.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 28/11/25.
//

import SwiftUI

struct ProfileButton: View {
    @State var showAccountPage: Bool = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Button(action: {
            vibrate(style: .medium)
         showAccountPage = true
        }) {
            Image(systemName: "person")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray)
                .frame(width: 30, height: 30)
                .padding(8)
                .background(
                    Circle()
                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.7))
                        .shadow(radius: 3)
                )
        }
        .padding(.horizontal, 4)
        .navigationDestination(isPresented: $showAccountPage) {
            AccountView()
        }
       
       }
}

#Preview {
    ProfileButton()
}
