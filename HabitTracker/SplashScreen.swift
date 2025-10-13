//
//  SplashScreen.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/10/25.
//
import SwiftUI

struct SplashScreen: View {
    @State private var fadeIn = false
    @State private var scale: CGFloat = 0.9
    @State private var underlineWidth: CGFloat = 0

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Habit Tracker")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .scaleEffect(scale)
                    .opacity(fadeIn ? 1 : 0)
                    .animation(.easeOut(duration: 1), value: fadeIn)
                    .animation(.spring(response: 1.2, dampingFraction: 0.6), value: scale)

                Rectangle()
                    .fill(Color.primary)
                    .frame(width: underlineWidth, height: 2)
                    .opacity(fadeIn ? 1 : 0)
                    .animation(.easeInOut(duration: 0.8).delay(0.6), value: underlineWidth)
            }
            .onAppear {
                fadeIn = true
                scale = 1.05
                underlineWidth = 100
            }
        }
    }
}
