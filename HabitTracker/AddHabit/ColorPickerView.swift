//
//  ColorPickerView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 15/08/25.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: Color
    private let paletteColors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .gray]
    var body: some View {
        HStack(spacing: 15) {
            ForEach(paletteColors, id: \.self) { color in
                Button(action:{
                    selectedColor = color
                    vibrate(style: .soft)
                }){
                    ZStack {
                        if selectedColor == color {
                            Circle()
                                .stroke(color, lineWidth: 4)
                                .frame(width: 40, height: 40)
                        }

                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .frame(height: 40)
    }
}

#Preview {
    ColorPickerView(selectedColor: .constant(.red))
}
