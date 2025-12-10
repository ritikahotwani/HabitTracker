//
//  OnboardingSegmentController.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 23/08/25.
//

import SwiftUI

struct OnboardingSegmentController: View {
    @Binding var selectedOption: OnboardingOption
    

    
    var body: some View {
        Picker("", selection: $selectedOption) {
            ForEach(OnboardingOption.allCases, id: \.self) {
                Text($0.title)
            }
        }
        .pickerStyle(.segmented)
        
        .tint(.black)
        .padding()
    }
}


#Preview {
    OnboardingSegmentController(selectedOption: .constant(.signIn))
}
