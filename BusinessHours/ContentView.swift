//
//  ContentView.swift
//  BusinessHours
//
//  Created by Tingzhi Li on 6/3/24.
//

import SwiftUI

struct ContentView: View {
    @State private var businessLocation = BusinessLocation()
    @State private var dailyHoursArray = [DailyHours]()
    @State private var showFullHours = false
    
    var body: some View {
        ZStack {
            // background
            //
            RadialGradient(stops: [
                .init(color: .mint, location: 0.3),
                .init(color: .orange, location: 0.3)
            ], center: .top, startRadius: 300, endRadius: 700)
            .ignoresSafeArea()
            
            VStack {
                HeaderView(headerText: businessLocation.locationName)
                    .foregroundStyle(.white)
                
                // hours accordion
                //
                List {
                    Section {
                        if showFullHours {
                            VStack(spacing: 8) {
                                Divider()
                                    .padding(.bottom, 16)
                                
                                ForEach(weekdayNormalOrder(), id: \.self) { weekdayNumber in
                                    let fullHours = fullHours()
                                    if let hours = fullHours[weekdayNumber] {
                                        BusinessHourRowItemView(dayOfWeekNumber: weekdayNumber,
                                                                openingHours: hours)
                                        .fontWeight(highlightWeekdayNumber() == weekdayNumber ? .bold : .regular)
                                    }
                                }
                            }
                            .padding(.bottom, 12)
                            .listRowBackground(Color.clear.background(.regularMaterial))
                            .listRowSeparator(.hidden)
                        }
                    } header: {
                        BusinessHoursSectionHeaderView(headerText: sectionHeaderText(),
                                                       statusColor: businessStatus().color,
                                                       showFullHours: $showFullHours)
                    }
                    .textCase(nil)
                }
                .listStyle(.plain)
                .padding(.horizontal)
                
                // view menu button
                //
                Button {
                    print("View Menu button is tapped.")
                } label: {
                    MenuButtonView()
                        .foregroundStyle(.white)
                }
            }
        }
        .task {
            await loadData()
        }
    }
}

extension ContentView {
    private func loadData() async {
        let urlStr = "https://purs-demo-bucket-test.s3.us-west-2.amazonaws.com/location.json"
        guard let url = URL(string: urlStr) else {
            print("Invalid url")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(BusinessLocation.self, from: data) {
                businessLocation = decodedResponse
                dailyHoursArray = process(businessHours: businessLocation.hours)
            }
        } catch {
            print("Invalid data")
        }
    }
    
    private func process(businessHours: [BusinessLocation.BusinessHour]) -> [DailyHours] {
        var dict = [Int: [OpeningHour]]()
        for businessHour in businessHours {
            let weekdayNumber = Utility.extractWeekdayNumber(from: businessHour.dayOfWeek)
            
            let adjustedStart = businessHour.startLocalTime == "24:00:00" ? "00:00:00" : businessHour.startLocalTime
            let adjustedEnd = businessHour.endLocalTime == "24:00:00" ? "00:00:00" : businessHour.endLocalTime

            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let startDate = formatter.date(from: adjustedStart) ?? .now
            let endDate = formatter.date(from: adjustedEnd) ?? .now
            
            let openingHour = OpeningHour(startDate: startDate, endDate: endDate)
                        
            var value = dict[weekdayNumber] ?? []
            if !value.contains(where: { $0.startDate == startDate && $0.endDate == endDate }) {
                value.append(openingHour)
            }
            dict[weekdayNumber] = value
        }
        
        // sort array of OpeningHour
        //
        var dailyHoursArray = [DailyHours]()
        for key in dict.keys {
            dict[key]?.sort { $0.startDate < $1.startDate }
            
            if let hours = dict[key] {
                dailyHoursArray.append(DailyHours(weekdayNumber: key, hours: hours))
            }
        }
        
        // sort array of DailyHours
        //
        dailyHoursArray.sort { $0.weekdayNumber < $1.weekdayNumber }
        
        for (idx, dailyHours) in dailyHoursArray.enumerated() {
            if let firstBlock = dailyHours.hours.first, firstBlock.startDate.isMidnight {
                let hour1 = Calendar.current.component(.hour, from: firstBlock.endDate)
                if  hour1 > 0 && hour1 <= 6 {
                    // hour1 == 0 means the 24h open case, exclude this case
                    // 6AM is the threshold where we consider it is part of the previous day
                    // after 6AM, we consider it is part of today
                    //
                    dailyHoursArray[idx].carryoverPrevious = firstBlock
                }
                
                let previousWeekday = Utility.previousWeekdayNumber(from: dailyHours.weekdayNumber)
                if let idx = dailyHoursArray.firstIndex(where: { $0.weekdayNumber == previousWeekday }) {
                    dailyHoursArray[idx].carryoverNext = firstBlock
                }
            }
        }
        return dailyHoursArray
    }
    
    private func fullHours() -> [Int: [OpeningHour]] {
        var dict = [Int: [OpeningHour]]()
        for dailyHour in dailyHoursArray {
            var openingHours = dailyHour.hours
            if dailyHour.carryoverPrevious != nil {
                _ = openingHours.removeFirst()
            }
            if let next = dailyHour.carryoverNext {
                if let date1 = openingHours.last?.endDate {
                    let date2 = next.startDate
                    let hour1 = Calendar.current.component(.hour, from: date1)
                    let hour2 = Calendar.current.component(.hour, from: date2)
                    if hour1 == hour2 {
                        openingHours[openingHours.count - 1].endDate = next.endDate
                    }
                }
            }
            dict[dailyHour.weekdayNumber] = openingHours
        }
        
        return dict
    }
    
    // for example: if today is Wednesday (4), then the array will be [3,4,5,6,7,1,2]
    // it will always include yesterday's weekday number
    //
    private func weeekdayRotatingOrder() -> [Int] {
        Array(Utility.previousWeekdayNumber()...7) + Array(1..<Utility.previousWeekdayNumber())
    }
    
    // Sunday -> Saturday order
    //
    private func weekdayNormalOrder() -> [Int] {
        Array(1...7)
    }
    
    private func businessStatus() -> BusinessStatus {
        let currentWeekdayNumber = Utility.currentWeekdayNumber()
        
        if let dailyHours = dailyHoursArray.first(where: { $0.weekdayNumber == currentWeekdayNumber }) {
            for hour in dailyHours.hours {
                let endHour = Calendar.current.component(.hour, from: hour.endDate)
                var endDate = hour.endDate
                if endHour == 0 {
                    // "23:59:59"
                    //
                    let components = DateComponents(year: 2000, month: 1, day: 1, hour: 23, minute: 59, second: 59)
                    endDate = Calendar.current.date(from: components) ?? hour.endDate
                }
                let startDate = hour.startDate
                
                let currentTime = Utility.currentTimeObject()
                
                if startDate <= endDate {
                    let range = startDate...endDate
                    if range.contains(currentTime) {
                        // assume minimum 1 hr operation hour time per time block
                        //
                        let newStartDate = endDate.addingTimeInterval(-3600)
                        let newRange = newStartDate...endDate
                        if newRange.contains(currentTime) {
                            return .willCloseInAnHour
                        }
                        return .open
                    }
                } else {
                    print("Error: startDate\(startDate) is greater than endDate\(endDate)!!!")
                }
            }
        }
        return .closed
    }
        
    private func sectionHeaderText() -> String {
        let isOpen = businessStatus().isOpen
        let current = Utility.current
        let currentTime = Utility.currentTimeObject()

        if isOpen {
            // open until {time} or
            // open until {time}, reopens at {next time block}
            //
            if let dailyHours = dailyHoursArray.first(where: { $0.weekdayNumber == Utility.currentWeekdayNumber()}) {
                
                for (idx, dailyHour) in dailyHours.hours.enumerated() {
                    let startDate = dailyHour.startDate
                    let endDate = dailyHour.endDate
                    var newEndDate = dailyHour.endDate
                    if Calendar.current.component(.hour, from: endDate) == 0 {
                        // "23:59:59"
                        let components = DateComponents(year: 2000, month: 1, day: 1, hour: 23, minute: 59, second: 59)
                        newEndDate = Calendar.current.date(from: components) ?? endDate
                    }
                    if startDate <= newEndDate {
                        let range = startDate...newEndDate
                        if range.contains(currentTime) {
                            // found the match
                            // search to see if there is a reopen time
                            if idx == dailyHours.hours.count - 1 {
                                // last time block
                                return "Open until \(Utility.convertDateToHourStr(endDate))"
                            } else {
                                let reopenDate = dailyHours.hours[idx + 1].startDate
                                return "Open until \(Utility.convertDateToHourStr(endDate)), reopens at \(Utility.convertDateToHourStr(reopenDate))"
                            }
                        }
                    } else {
                        print("Error: startDate\(startDate) is greater than newEndDate\(newEndDate)!!!")
                    }
                }
            }
        } else {
            // opens again at {time} or
            // opens {day} {time}
            //
            // find the first time block after current time
            // could be on the same day
            // or on a different day
            //
            let currentWeekdayNumber = Utility.currentWeekdayNumber()
            
            var foundNextTime = false
            var savedTime: Date?
            if let dailyHours = dailyHoursArray.first(where: { $0.weekdayNumber == currentWeekdayNumber }) {
                for dailyHour in dailyHours.hours {
                    if currentTime < dailyHour.startDate {
                        // found next time block
                        //
                        savedTime = dailyHour.startDate
                        foundNextTime = true
                    }
                }
                if foundNextTime {
                    // should be within 24 hrs since it is found in the same day
                    //
                    return "Opens again at \(Utility.convertDateToHourStr(savedTime ?? Utility.current))"
                } else {
                    // find the first time block of the next existing weekday's hours
                    //
                    if let index = dailyHoursArray.firstIndex(where: { $0.weekdayNumber == currentWeekdayNumber}) {
                        let currentHour = Calendar.current.component(.hour, from: current)

                        if index + 1 < dailyHoursArray.count {
                            let nextDailyHours = dailyHoursArray[index + 1]
                            let nextTime = nextDailyHours.hours.first?.startDate ?? .now
                            let nextWeekday = nextDailyHours.weekdayNumber
                            let nextHour = Calendar.current.component(.hour, from: nextTime)
                            
                            let hourDiff = hourDiff(weekday1: currentWeekdayNumber,
                                                    hour1: currentHour,
                                                    weekday2: nextWeekday,
                                                    hour2: nextHour)
                            
                            if hourDiff > 24 {
                                return "Opens \(Utility.convertWeekdayNumberToWeekdayStr(nextWeekday)) \(Utility.convertDateToHourStr(nextTime))"
                            } else {
                                return "Opens again at \(Utility.convertDateToHourStr(nextTime))"
                            }
                        } else {
                            let nextDailyHours = dailyHoursArray[0]
                            let nextTime = dailyHoursArray[0].hours.first?.startDate ?? .now
                            let nextWeekday = nextDailyHours.weekdayNumber
                            let nextHour = Calendar.current.component(.hour, from: nextTime)
                            
                            let hourDiff = hourDiff(weekday1: currentWeekdayNumber,
                                                    hour1: currentHour,
                                                    weekday2: nextWeekday,
                                                    hour2: nextHour)
                            
                            if hourDiff > 24 {
                                return "Opens \(Utility.convertWeekdayNumberToWeekdayStr(nextWeekday)) \(Utility.convertDateToHourStr(nextTime))"
                            } else {
                                return "Opens again at \(Utility.convertDateToHourStr(nextTime))"
                            }
                        }
                    }
                }
            }
        }
        return ""
    }
    
    private func hourDiff(weekday1: Int, hour1: Int, weekday2: Int, hour2: Int) -> Int {
        let totalHours1 = weekday1 * 24 + hour1
        let totalHours2 = weekday2 * 24 + hour2
        return abs(totalHours1 - totalHours2)
    }
    
    private func highlightWeekdayNumber() -> Int {
        // only highlight previous day if current time falls within yesterday's last time block
        //
        if let dailyHours = dailyHoursArray.first(where: { $0.weekdayNumber == Utility.currentWeekdayNumber() }) {
            if let previous = dailyHours.carryoverPrevious {
                let currentTime = Utility.currentTimeObject()
                let startDate = previous.startDate
                let endDate = previous.endDate
                
                if startDate <= endDate {
                    let range = startDate...endDate
                    if range.contains(currentTime) {
                        return Utility.previousWeekdayNumber()
                    }
                } else {
                    print("Error: startDate is greater than endDate!!!")
                }
            }
        }
        return Utility.currentWeekdayNumber()
    }
}

#Preview {
    ContentView()
}
