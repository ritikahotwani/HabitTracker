//
//  CircularProgressView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 14/08/25.
//

import SwiftUI
struct CircularProgressView: View {
    let progress: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.30), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
        .frame(width: 15, height: 15)
    }
}

#Preview {
    CircularProgressView(progress: 0.7, color: .red)
}



