//
//  BusinessHourRowItemView.swift
//  BusinessHours
//
//  Created by Tingzhi Li on 6/3/24.
//

import SwiftUI

struct BusinessHourRowItemView: View {
    var dayOfWeekNumber: Int
    var openingHours: [OpeningHour]
    
    var body: some View {
        HStack(alignment: .top) {
            Text(Utility.convertWeekdayNumberToWeekdayStr(dayOfWeekNumber))
            Spacer()
            VStack(alignment: .trailing) {
                ForEach(openingHours) { openingHour in
                    let start = Utility.convertDateToHourStr(openingHour.startDate)
                    let end = Utility.convertDateToHourStr(openingHour.endDate)
                    Text("\(start)-\(end)")
                }
            }
        }
    }
}

#Preview {
    let dayOfWeekNumber = 2  // Monday
    let openingHours = Utility.exampleOpeningHours
    return BusinessHourRowItemView(dayOfWeekNumber: dayOfWeekNumber,
                            openingHours: openingHours)
}
