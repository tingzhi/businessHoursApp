//
//  Utility.swift
//  BusinessHours
//
//  Created by Tingzhi Li on 6/3/24.
//

import Foundation

struct Utility {
    static let formatter = DateFormatter()
    static let exampleOpeningHours = [OpeningHour(startDate: Date.now.addingTimeInterval(-3600), endDate: Date.now),
                                      OpeningHour(startDate: Date.now.addingTimeInterval(30 * 60), endDate: Date.now.addingTimeInterval(4 * 3600))]
    
    static func convertDateToHourStr(_ date: Date) -> String {
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
    
    static func convertWeekdayNumberToWeekdayStr(_ num: Int) -> String {
        switch num {
        case 1: return "Sunday"
        case 2: return "Monday"
        case 3: return "Tuesday"
        case 4: return "Wednesday"
        case 5: return "Thursday"
        case 6: return "Friday"
        case 7: return "Saturday"
        default: return ""
        }
    }
    
    // input: "SUN"
    // output: 1
    //
    static func extractWeekdayNumber(from weekOfDayStr: String) -> Int {
        formatter.dateFormat = "E"
        let date = formatter.date(from: weekOfDayStr) ?? .now
        return Calendar.current.dateComponents([.weekday], from: date).weekday ?? 1
    }

    static func currentWeekdayNumber() -> Int {
        return Calendar.current.dateComponents([.weekday], from: self.current).weekday ?? 1
    }
    
    static let debugMode = false
    static let hours = 7.0
    static let testDate = Date.now.addingTimeInterval(hours * 3600)
    static let current = debugMode ? testDate : Date.now
    
    static func previousWeekdayNumber() -> Int {
        if currentWeekdayNumber() > 1 {
            return currentWeekdayNumber() - 1
        } else {
            return 7
        }
    }
    
    static func previousWeekdayNumber(from weekdayNumber: Int) -> Int {
        if weekdayNumber - 1 > 1 {
            return weekdayNumber - 1
        } else {
            return 7
        }
    }
    
    static func nextWeekdayNumber() -> Int {
        if currentWeekdayNumber() < 7 {
            return currentWeekdayNumber() + 1
        } else {
            return 1
        }
    }
    
    static func currentTimeObject() -> Date {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: self.current)
        let timeComponents = DateComponents(year: 2000,
                                            month: 1,
                                            day: 1,
                                            hour: components.hour,
                                            minute: components.minute,
                                            second: components.second)
        return Calendar.current.date(from: timeComponents) ?? .now
    }
}

extension Date {
    var isMidnight: Bool {
        Calendar.current.dateComponents([.hour], from: self).hour == 0
    }
}
