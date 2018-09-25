//
//  RoutineCreationTypes.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/8/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation

protocol ActivityCreationDelegate: class {
    func didUpdate(activityModel: CustomActivityModel?)
    func doneCreatingActivity()
}

protocol RoutineCreationDelegate: class {
    func didUpdate(routineModel: RoutineCreationViewModel?)
    func doneCreatingRoutine()
}

class RoutineCreationViewModel {
    var date: Date?
    var alertStyle: AlertStyle?
    var countdownReminders = AlertSchedule.supportedScheduleEntries.map {
        CountdownReminderViewModel(minutesLeft: $0)
    }

    var numSelectedReminders: Int {
        return countdownReminders.filter {
            $0.selected
        }.count
    }

    func setSelectedRemdinders(from reminderString: String?) {
        let alertSchedule = AlertSchedule(scheduleString: reminderString)

        guard alertSchedule.sortedDeadlines.count > 0 else {
            return
        }

        countdownReminders.forEach { (reminder) in
            if nil != alertSchedule.sortedDeadlines.index(where: { (entry) -> Bool in
                return entry == reminder.minutesLeft
            }) {
                reminder.selected = true
            }
        }
    }
}

class CustomActivityModel {
    var durationTime: Int?
    var tag: String?
    var iconName: String?
}

class CountdownReminderViewModel: CustomStringConvertible {
    private static var stringListDelimiter = ","
    let minutesLeft: UInt
    var selected = false

    init(minutesLeft: UInt) {
        self.minutesLeft = minutesLeft
    }

    var description: String {
        guard minutesLeft != 1 else {
            return NSLocalizedString("1 Min Left", comment: "One minute left")
        }
        return NSLocalizedString("\(minutesLeft) Mins Left", comment: "Greater than 1 minute left: '2 Mins Left'")
    }

    /// Returns the backend/server format for a set of reminders
    static func reminderString(from reminders: [CountdownReminderViewModel]) -> String {
        let array = reminders.filter {
            $0.selected
        }.map {
            $0.minutesLeft
        }.sorted() // Sort ascending to match the way the server stores this
        return AlertSchedule.from(minutesArray: array).scheduleString ?? ""
    }
}
