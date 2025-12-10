//
//  ButtonViewModifier.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 19/08/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 40)
            .padding(.vertical, 6)
            .background(AppGradient.purple.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
//            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

