//
//  ProfileView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 28/11/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var vm: HabitTrackerViewModel

    var body: some View {
        VStack {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
                .foregroundColor(.white)
                .padding(20)
                .background(
                    Circle()
                        .fill(AppGradient.lightpurple)
                )
                .frame(width: 120, height: 120)
            
            if let user = vm.currentUser {
                Text("\(user.userName ?? "")")
                    .font(.system(size: 35, weight: .bold))
                
                
                Text("\(user.userEmail ?? "")")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.gray)
            }
        }
    }
}


#Preview {
    ProfileView()
}
