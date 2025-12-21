//
//  HeaderView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//
import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var vm: HabitTrackerViewModel
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let user = vm.currentUser {
                    Text("Hello,")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppGradient.purple)
                    
                    Text("\(user.userName ?? "")")
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundStyle(.black)
                }
            }
            Spacer()

            AddButton()
            ProfileButton()
        }
        .padding(.vertical)
        .padding(.horizontal)
    }
}




#Preview {
    HeaderView()
}
