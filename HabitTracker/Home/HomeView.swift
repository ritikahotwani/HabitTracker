//
//  HomeView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 14/08/25.
//
import SwiftUI

struct HomeView: View {
    @State private var newHabit = ""
    @State private var dates: [Date] = []
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    
    var body: some View {
        NavigationStack{
            VStack() {
                HeaderView()
                HabitList( dates: $dates)
                
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            
            .onAppear {
                dates = viewModel.loadRecentDates()
            }
        }
    }
}

#Preview {
    HomeView()
}
