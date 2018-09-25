//
//  ElapsedTimePresenter.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/9/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

private struct TimeRemainingStrings {
    static let youHave = NSLocalizedString("You have ", comment: "The first part of 'You have <n> minute(s) remaining in your activity'; with a space at the end")
    static let remaining = NSLocalizedString(" remaining in your activity", comment: "The last part of 'You have <n> minute(s) remaining in your activity'; with a space at the beginning")
    static let oneMinute = NSLocalizedString("1 minute", comment: "As in, 'You have 1 minute remaining in your activity'")

    static func minutesString(for minutes: UInt) -> String {
        let manyMinutes = NSLocalizedString("\(minutes) minutes", comment: "As in, 'You have 10 minute remaining in your activity' (plural minutes)")
        return minutes == 1 ? oneMinute : manyMinutes
    }
}

struct ElapsedTimePresenter {
    let seconds: Int

    var wholeHours: Int {
        return seconds / Constants.secondsInHour
    }

    var wholeMinutesRemainder: Int {
        return (seconds % Constants.secondsInHour) / Constants.secondsInMinute
    }

    var secondsRemainder: Int {
        return seconds % Constants.secondsInMinute
    }

    /// hh:mm:ss
    var stopwatchStringLong: String {
        return String(format: "%02d:%02d:%02d", wholeHours, wholeMinutesRemainder, secondsRemainder)
    }

    /// hh:mm, or mm:ss. Uses "ceiling" for minutes: One hour, 9 minutes 1 second appears as "01:10"
    var stopwatchStringShort: String {
        if seconds < Constants.secondsInHour {
            // Return minutes and seconds
            return String(format: "%02d:%02d", wholeMinutesRemainder, secondsRemainder)
        } else {
            // Return hours and minutes
            var minutes = wholeMinutesRemainder + (secondsRemainder > 0 ? 1 : 0)
            var hours = wholeHours
            if minutes == Constants.minutesInHour {
                minutes = 0
                hours += 1
            }
            return String(format: "%02d:%02d", maxStopwatchHours(for: hours), minutes)
        }
    }

    var stopwatchStringShortWithBiggestUnits: String {
        let timeString = stopwatchStringShort
        if seconds < Constants.secondsInHour {
            return NSLocalizedString("\(timeString)", comment: "e.g., '10:00 min' (minutes)")
        } else {
            return NSLocalizedString("\(timeString)", comment: "e.g., '10:00 hour' (hours)")
        }
    }

    /// Less than one hour, even minute mark: "10 min"
    /// Less than one hour, not on even minute mark: "12 min 31 sec"
    /// One hour or greater with 0 minutes and 0 seconds: "2 hr"
    /// One hour or greater with > 0 minutes or seconds: "2 hr 10 min"
    var hoursAndMinutesStringShort: String {
        if seconds < Constants.secondsInHour {
            let sec = secondsRemainder
            let minutes = wholeMinutesRemainder
            if sec == 0 {
                return NSLocalizedString("\(minutes) min", comment: "")
            } else {
                return NSLocalizedString("\(minutes) min \(sec) sec", comment: "")
            }
        } else {
            var hours = maxStopwatchHours(for: wholeHours)
            var minutes = wholeMinutesRemainder + (secondsRemainder > 0 ? 1 : 0)

            if minutes == Constants.minutesInHour {
                minutes = 0
                hours += 1
            }

            if minutes == 0 {
                return NSLocalizedString("\(hours) hr", comment: "")
            } else {
                return NSLocalizedString("\(hours) hr \(minutes) min", comment: "")
            }
        }
    }

    var doneTimeString: String {
        let date = Date().addingTimeInterval(TimeInterval(seconds))
        return DateFormatter.timeFormatter.string(from: date)
    }

    /// Stopwatch hours has two digits, so it only goes up to 99 hours, sorry.
    private func maxStopwatchHours(for hours: Int) -> Int {
        return min(hours, 99)
    }
}

// Static "Time Remaining" methods
extension ElapsedTimePresenter {
    static func timeRemainingString(for minutesRemaining: UInt) -> String {
        return TimeRemainingStrings.youHave + TimeRemainingStrings.minutesString(for: minutesRemaining) + TimeRemainingStrings.remaining
    }

    static func attributedTimeRemainingString(for minutesRemaining: UInt) -> NSAttributedString {
        // Probably should factor these style definitions out, making this configurable
        let size: CGFloat = 14
        let font = UIFont.book(size)
        let boldFont = UIFont.heavy(size)

        let attrYouHave = NSMutableAttributedString(string: TimeRemainingStrings.youHave)
        let attrMinutes = NSMutableAttributedString(string: TimeRemainingStrings.minutesString(for: minutesRemaining))
        let attrRemaining = NSMutableAttributedString(string: TimeRemainingStrings.remaining)

        [attrYouHave, attrRemaining].forEach {
            $0.addAttributes([NSAttributedStringKey.font: font], range: NSRange(location: 0, length: $0.length))
        }
        attrMinutes.addAttributes([NSAttributedStringKey.font: boldFont], range: NSRange(location: 0, length: attrMinutes.length))

        let message = NSMutableAttributedString()
        message.append(attrYouHave)
        message.append(attrMinutes)
        message.append(attrRemaining)
        return message
    }
}
