//
//  LocalNotificationConfig.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/15/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation
import UserNotifications

struct LocalNotificationConfig {
    /**
     * Adds notifications for:
     *   Before:
     *     30 minutes before, 10 minutes before, 5 minutes before, starting now
     *   During:
     *     reminder for every countdown alert a user schedules
     *   Complete:
     *     "Wayy complete, have a great day!"
     */
    let entries: [RoutineNotificationCreator]

    init?(routine: Routine) {
        guard
            let name = routine.getTemplate()?.name,
            let id = routine.id,
            let reminders = routine.reminder
        else {
            logError()
            return nil
        }

        var entries = [RoutineNotificationCreator]()

        // Add entries for "<routine name> starts in n minutes"
        // Use something like the commented out array for easier testing of notifications.
        //let notificationPreStartDeltas = [-5,-4,-3,-2,-1,0]
        let notificationPreStartDeltas = [-30, -10, -5, 0]
        for minutes in notificationPreStartDeltas {
            let message = LocalNotificationConfig.minutesBeforeMessage(minutesBefore: UInt(abs(minutes)), routineName: name)
            entries.append(RoutineNotificationCreator(routineName: name, routineId: id, minutesDelta: minutes, message: message))
        }

        // Add entries for "n minutes remaining in <routine name>"
        var deadlines = AlertSchedule(scheduleString: reminders).sortedDeadlines
        deadlines.append(0)
        for deadline in deadlines {
            // Ensure the Wayy is longer than this deadline
            let delta = routine.duration() - Int(deadline)
            guard delta > 0 else { continue }

            let message = LocalNotificationConfig.minutesRemainingMessage(minutesRemaining: deadline, routineName: name)
            entries.append(RoutineNotificationCreator(routineName: name, routineId: id, minutesDelta: delta, message: message))
        }

        self.entries = entries
    }

    private static func minutesBeforeMessage(minutesBefore: UInt, routineName: String) -> String {
        if minutesBefore == 0 {
            return NSLocalizedString("'\(routineName)' starts now", comment: "")
        } else if minutesBefore == 1 {
            return NSLocalizedString("'\(routineName)' starts in 1 minute", comment: "")
        } else {
            return NSLocalizedString("'\(routineName)' starts in \(minutesBefore) minutes", comment: "")
        }
    }

    private static func minutesRemainingMessage(minutesRemaining: UInt, routineName: String) -> String {
        if minutesRemaining == 0 {
            return NSLocalizedString("Wayy complete, have a great day!", comment: "")
        } else if minutesRemaining == 1 {
            return NSLocalizedString("1 minute remaining in '\(routineName)'", comment: "")
        } else {
            return NSLocalizedString("\(minutesRemaining) minutes remaining in '\(routineName)'", comment: "")
        }
    }
}
