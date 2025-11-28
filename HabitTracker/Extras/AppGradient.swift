//
//  AppGradient.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 28/11/25.
//

import Foundation
import SwiftUI

struct AppGradient {
    static let purpleMauve = LinearGradient(
        colors: [
            Color(#colorLiteral(red: 0.77, green: 0.68, blue: 0.92, alpha: 1)),
            Color(#colorLiteral(red: 0.56, green: 0.44, blue: 0.87, alpha: 1))
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let purple = Color(#colorLiteral(red: 0.56, green: 0.44, blue: 0.87, alpha: 1))

    static let lightpurple = Color(#colorLiteral(red: 0.77, green: 0.68, blue: 0.92, alpha: 1))

}
