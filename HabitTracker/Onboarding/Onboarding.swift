//
//  Onboarding.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 23/08/25.
//

import SwiftUI

struct Onboarding: View {
    @State private var selectedOption: OnboardingOption = .signIn
    var body: some View {
        
        VStack() {
          
            AppHeader()
            OnboardingSegmentController(selectedOption: $selectedOption)
            
            TabView(selection: $selectedOption) {
                SignInForm()
                    .tag(OnboardingOption.signIn)
                
                SignUpForm()
                    .tag(OnboardingOption.signUp)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedOption)
        }
        .padding(.top, 120)
    }
}

#Preview {
    Onboarding()
}





