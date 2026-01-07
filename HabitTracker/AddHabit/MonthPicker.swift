//
//  MonthPicker.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 15/08/25.
//

import SwiftUI

struct MonthPicker: View {
    @Binding  var monthSelected: Months
    var body: some View {
        Picker("Month",selection: $monthSelected){
            ForEach(Months.allCases){ month in
                Text(month.rawValue)
            }
        }
        .tint(.primary)
    }
}

#Preview {
    MonthPicker(monthSelected: .constant(.Aug))
}
