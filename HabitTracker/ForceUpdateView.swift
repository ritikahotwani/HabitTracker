//
//  ForceUpdateView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 08/01/26.
//

import SwiftUI

struct ForceUpdateView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "arrow.down.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                
                Text("Update Required")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("A new version of Habit Tracker is available. Please update to continue using the app.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Button(action: {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id6755728089") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Update Now")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

#Preview {
    ForceUpdateView()
}
