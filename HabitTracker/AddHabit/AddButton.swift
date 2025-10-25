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
    var body: some View {
        Button(action: {
         showAddHabit = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.trailing, 10)
        }
        .sheet(isPresented: $showAddHabit){
            AddHabit()
        }
       
       }
        
}

#Preview {
    AddButton()
}



