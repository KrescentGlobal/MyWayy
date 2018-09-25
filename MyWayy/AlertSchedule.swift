//
//  AlertSchedule.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/22/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

struct AlertSchedule: CustomDebugStringConvertible {
    /// Supported schedule entries in minutes
    static let supportedScheduleEntries: [UInt] = [90, 60, 30, 20, 10, 5, 3, 1]

    var debugDescription: String {
        return "\(String(describing: AlertSchedule.self)): \(sortedDeadlines))"
    }

    /// 24 hours
    private static let maxMinutes: UInt = UInt(Constants.hoursInDay) * UInt(Constants.minutesInHour)
    private static let delimiter = ","
    private static let emptySchedule = [UInt]()

    let sortedDeadlines: [UInt]
    var scheduleString: String?

    init(scheduleString: String?) {
        // Sort largest to smallest, since the schedule entries represent time remaining.
        sortedDeadlines = AlertSchedule.parse(scheduleString).sorted().reversed()

        if sortedDeadlines.count > 0 {
            // If the array is not empty, scheduleString is valid
            self.scheduleString = scheduleString
        }
    }

    static func from(minutesArray: [UInt]) -> AlertSchedule {
        let string = minutesArray.reduce("", { (string, minutes) in
            if string.isEmpty {
                return String(minutes)
            } else {
                return "\(string)\(delimiter) \(minutes)"
            }
        })
        return AlertSchedule(scheduleString: string)
    }

    /// Returns a tuple indicating whether the schedule contains a schedule entry
    /// at secondsRemaining, and if so, the index of that entry in the
    /// reverse-sorted schedule. If there is no entry, the index returned is 0.
    func hasScheduleEntry(at secondsRemaining: UInt) -> (Bool, Int) {
        let noEntry: (Bool, Int) = (false, 0)
        let isEvenMinute = secondsRemaining % UInt(Constants.secondsInMinute) == 0
        let entry = secondsRemaining / UInt(Constants.secondsInMinute)

        guard isEvenMinute && sortedDeadlines.contains(entry) else { return noEntry }

        guard let index = sortedDeadlines.index(where: { $0 == entry }) else {
            logError("Cannot find \(entry) in \(sortedDeadlines)!")
            return noEntry
        }

        return (true, index)
    }

    private static func parse(_ scheduleString: String?) -> [UInt] {
        guard var string = scheduleString, string != "none" else {
            return AlertSchedule.emptySchedule
        }

        // Remove spaces. Also, the "mins left" and other text is present in
        // reminders in routines created earlier in the project. Once the app is
        // in production, these lines can be remvoed.
        string = string.replacingOccurrences(of: "mins left", with: "")
        string = string.replacingOccurrences(of: "min left", with: "")
        string = string.replacingOccurrences(of: " ", with: "")
        string = string.replacingOccurrences(of: "M", with: "")
        let components = string.components(separatedBy: AlertSchedule.delimiter)

        var schedule = AlertSchedule.emptySchedule

        guard !components.isEmpty else {
            logDebug("No entries in alert schedule: '\(string)'")
            return schedule
        }

        for component in components {
            guard component.count != 0 else { continue }
            guard let minutes = UInt(component) else {
                logError("Could not parse '\(component)'!")
                continue
            }
            guard minutes <= AlertSchedule.maxMinutes else {
                logError("'\(component)' exceeds \(AlertSchedule.maxMinutes) minutes!")
                continue
            }
            schedule.append(minutes)
        }

        return schedule
    }
}
