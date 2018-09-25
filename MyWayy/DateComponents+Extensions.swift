//
//  DateComponents+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/15/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation

extension DateComponents {
    /// TODO: This code should be unit tested!
    func apply(minutesDelta: Int) -> DateComponents? {
        var components = self

        guard var cMinutes = components.minute, var cHours = components.hour, var cWeekDay = components.weekday else {
            logError(String(describing: self))
            return nil
        }

        cMinutes += minutesDelta

        // One can create date components with, say, minutes set to > 60 or < 0,
        // and then create valid dates from them, even though the DateComponents
        // state that are not a valid date. UNCalendarNotificationTrigger seems
        // to not accept DateComponents for which isValidDate is false, hence
        // the following adjustments.
        if cMinutes >= Constants.minutesInHour {
            cHours += cMinutes / Constants.minutesInHour
            cMinutes = cMinutes % Constants.minutesInHour
        } else if cMinutes < 0 {
            let absMinutes = abs(cMinutes)

            if absMinutes % Constants.minutesInHour == 0 {
                cMinutes = 0
                cHours -= absMinutes / Constants.minutesInHour
            } else {
                cMinutes = Constants.minutesInHour - (absMinutes % Constants.minutesInHour)
                cHours -= ((absMinutes / Constants.minutesInHour) + 1)
            }
        }

        if cHours >= Constants.hoursInDay {
            cWeekDay += cHours / Constants.hoursInDay
            cHours = cHours % Constants.hoursInDay
        } else if cHours < 0 {
            let absHours = abs(cHours)

            if absHours % Constants.hoursInDay == 0 {
                cHours = 0
                cWeekDay -= absHours / Constants.hoursInDay
            } else {
                cHours = Constants.hoursInDay - (absHours % Constants.hoursInDay)
                cWeekDay -= (absHours / Constants.hoursInDay) + 1
            }
        }

        while cWeekDay > OrdinalDay.maxValue {
            cWeekDay -= OrdinalDay.maxValue
        }

        components.weekday = cWeekDay
        components.hour = cHours
        components.minute = cMinutes

        return components
    }
}
