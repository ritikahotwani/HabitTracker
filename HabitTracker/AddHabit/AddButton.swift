//
//  AddButton.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 15/08/25.
//
import SwiftUI

struct AddButton: View {
    @EnvironmentObject var viewModel: HabitTrackerViewModel

    var body: some View {
           NavigationLink(destination: AddHabit()) {
               Image(systemName: "plus")
                   .font(.title2)
                   .foregroundColor(.gray)
                   .padding(.trailing, 10)
           }
       }
}

#Preview {
    AddButton()
}



