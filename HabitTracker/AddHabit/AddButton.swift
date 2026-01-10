//
//  AddButton.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 15/08/25.
//
import SwiftUI

struct AddButton: View {
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @State var showAddHabit: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            vibrate(style: .medium)
         showAddHabit = true
        }) {
            Image(systemName: "plus")
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
        .sheet(isPresented: $showAddHabit){
            AddHabit()
        }
       
       }
        
}

#Preview {
    AddButton()
}



