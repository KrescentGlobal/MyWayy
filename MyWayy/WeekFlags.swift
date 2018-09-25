//
//  WeekFlags.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/14/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

protocol WeekFlagsOwner {
    var sunday: Bool? { get set }
    var monday: Bool? { get set }
    var tuesday: Bool? { get set }
    var wednesday: Bool? { get set }
    var thursday: Bool? { get set }
    var friday: Bool? { get set }
    var saturday: Bool? { get set }
}

enum OrdinalDay: Int {
    // Note that iOS uses 1-7 for Calendar.weekday
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    static let maxValue = 7

    var shortAbbreviatedDayString: String {
        switch self {
        case .sunday:
            return NSLocalizedString("S", comment: "'S' for Sunday")
        case .monday:
            return NSLocalizedString("M", comment: "'M' for Monday")
        case .tuesday:
            return NSLocalizedString("T", comment: "'T' for Tuesday")
        case .wednesday:
            return NSLocalizedString("W", comment: "'W' for Wednesday")
        case .thursday:
            return NSLocalizedString("T", comment: "'T' for Thursday")
        case .friday:
            return NSLocalizedString("F", comment: "'F' for Frday")
        case .saturday:
            return NSLocalizedString("S", comment: "'S' for Saturday")
        }
    }

    var abbreviatedDayString: String {
        switch self {
        case .sunday:
            return NSLocalizedString("Sun", comment: "'Sun' for Sunday")
        case .monday:
            return NSLocalizedString("Mon", comment: "'Mon' for Monday")
        case .tuesday:
            return NSLocalizedString("Tue", comment: "'Tue' for Tuesday")
        case .wednesday:
            return NSLocalizedString("Wed", comment: "'Wed' for Wednesday")
        case .thursday:
            return NSLocalizedString("Thu", comment: "'Thur' for Thursday")
        case .friday:
            return NSLocalizedString("Fri", comment: "'Fri' for Frday")
        case .saturday:
            return NSLocalizedString("Sat", comment: "'Sat' for Saturday")
        }
    }
}

struct WeekFlags {
    var sunday: Bool? = nil
    var monday: Bool? = nil
    var tuesday: Bool? = nil
    var wednesday: Bool? = nil
    var thursday: Bool? = nil
    var friday: Bool? = nil
    var saturday: Bool? = nil

    static func from(_ weekFlagsOwner: WeekFlagsOwner) -> WeekFlags {
        var weekFlags = WeekFlags()
        weekFlags.sunday = weekFlagsOwner.sunday
        weekFlags.monday = weekFlagsOwner.monday
        weekFlags.tuesday = weekFlagsOwner.tuesday
        weekFlags.wednesday = weekFlagsOwner.wednesday
        weekFlags.thursday = weekFlagsOwner.thursday
        weekFlags.friday = weekFlagsOwner.friday
        weekFlags.saturday = weekFlagsOwner.saturday
        return weekFlags
    }

    /// An array of OrdinalDays indicating the days of the week (1-7) that are "true"
    var setDays: [OrdinalDay] {
        
        let resDay = [(OrdinalDay.sunday,    sunday    ?? false),
                      (OrdinalDay.monday,    monday    ?? false),
                      (OrdinalDay.tuesday,   tuesday   ?? false),
                      (OrdinalDay.wednesday, wednesday ?? false),
                      (OrdinalDay.thursday,  thursday  ?? false),
                      (OrdinalDay.friday,    friday    ?? false),
                      (OrdinalDay.saturday,  saturday  ?? false)]
            
            
            
            
        let resDay2 = resDay.filter {
            return $0.1
            }.map {
                $0.0
        }
            
        return resDay2
    }

    var setDaysDebugDescription: String {
        let days = setDays
        guard days.count > 0 else {
            return "No set days"
        }
        var string = ""
        days.forEach { string.append("\($0.abbreviatedDayString)/\($0.rawValue), ") }
        return string
    }
}
