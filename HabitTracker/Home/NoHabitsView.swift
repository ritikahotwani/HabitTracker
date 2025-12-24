//
//  NoHabitsView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 28/11/25.
//

import SwiftUI

struct NoHabitsView: View {
    @State private var showAddHabit = false
    
    var body: some View {
        VStack(spacing: 12){
            Text("Start Your First Tiny Win")
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("A small habit creates big change tomorrow.")
                .font(.system(size: 12, weight: .regular))
                .multilineTextAlignment(.center)
                .padding(.bottom)
            Button {
                showAddHabit = true
            } label: {
                Text("Add New Habit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        AppGradient.lightpurple
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    )
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabit()
            }
            
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )        .padding()
        
    }
}

#Preview {
    NoHabitsView()
}
