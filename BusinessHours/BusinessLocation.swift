//
//  BusinessLocation.swift
//  BusinessHours
//
//  Created by Tingzhi Li on 6/3/24.
//

import Foundation
import SwiftUI

@Observable
class BusinessLocation: Codable, Identifiable {
    let id = UUID()
    let locationName: String
    let hours: [BusinessHour]
    
    enum CodingKeys: String, CodingKey {
        case locationName = "location_name"
        case hours
    }
    
    init() {
        self.locationName = ""
        self.hours = []
    }
    
    class BusinessHour: Codable, Identifiable {
        let id = UUID()
        let dayOfWeek: String
        let startLocalTime: String
        let endLocalTime: String
        
        init() {
            self.dayOfWeek = "WED"
            self.startLocalTime = "07:00:00"
            self.endLocalTime = "13:00:00"
        }
        
        enum CodingKeys: String, CodingKey {
            case dayOfWeek = "day_of_week"
            case startLocalTime = "start_local_time"
            case endLocalTime = "end_local_time"
        }
    }
}

struct DailyHours: Identifiable {
    let id = UUID()
    let weekdayNumber: Int
    let hours: [OpeningHour]
    var carryoverPrevious: OpeningHour? // which we will ignore when display full hours
    var carryoverNext: OpeningHour? // which we will combine with last hour
}

struct OpeningHour: Identifiable {
    let id = UUID()
    var startDate: Date
    var endDate: Date
}

enum BusinessStatus {
    case open, willCloseInAnHour, closed
    
    var color: Color {
        switch self {
        case .open: .green
        case .willCloseInAnHour: .yellow
        case .closed: .red
        }
    }
    
    var isOpen: Bool {
        self == .open || self == .willCloseInAnHour
    }
}
