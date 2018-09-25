//
//  RoutineHelpers.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/13/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

struct RoutineHelper {
    // MARK: Public

    static func tagStrings(from routineTags: String?) -> String? {
        guard let tags = routineTags else { return nil }
        let components = tags.components(separatedBy: " ").map { "#\($0)" }
        return components.joined(separator: " ")
    }

    static func getNextScheduledDate(from endTime: Date, durationMinutes: Int, weekFlags: WeekFlags) -> Date? {
        let startTime = endTime.addingTimeInterval(TimeInterval(-durationMinutes * Constants.secondsInMinute))
        let now = Date()
        for date in getNextOccurranceDates(for: startTime, now: now, weekFlags: weekFlags) {
            switch now.compare(date) {
            case .orderedAscending, .orderedSame:
                return date
            default:
                break
            }
        }

        logError()
        return nil
    }

    /// Returns an array of DateComponents with weekday, hour, minute and second
    /// set, with an array entry for each weekday that the routine is scheduled
    /// to run on. These represent the routine start times within a given week.
    static func getNotificationDateComponentsArray(for routine: Routine?) -> [DateComponents]? {
        guard let r = routine, let endDate = r.endTimeAsDate() else {
            logError()
            return nil
        }

        let weekFlags = WeekFlags.from(r)
        let startDate = endDate.addingTimeInterval(TimeInterval(-r.durationInSeconds))
        let flags = Set<Calendar.Component>([.hour, .minute, .second])
        var array = [DateComponents]()

        weekFlags.setDays.forEach {
            var components = NSCalendar.current.dateComponents(flags, from: startDate)
            components.weekday = $0.rawValue
            array.append(components)
        }

        return array
    }

    static func attributedNextScheduledDate(from nextOccuranceDate: Date,
                                            withNewline: Bool,
                                            descriptionColor: UIColor = UIColor.with(Rgb.routineCellDarkGray),
                                            dateTimeColor: UIColor = UIColor.lightishBlueFullAlpha) -> NSAttributedString {
        let attrFontSize: CGFloat = 14
        let prefix =
            NSMutableAttributedString(string: NSLocalizedString("Next scheduled date is:\(withNewline ? "\n" : " ")", comment: ""),
                                      attributes: [NSAttributedStringKey.font: UIFont.book(attrFontSize),
                                                   NSAttributedStringKey.foregroundColor: descriptionColor])

        let dateTimeAttributes = [NSAttributedStringKey.font: UIFont.heavy(attrFontSize),
                                  NSAttributedStringKey.foregroundColor: dateTimeColor]
        let otherAttributes = [NSAttributedStringKey.font: UIFont.book(attrFontSize),
                               NSAttributedStringKey.foregroundColor: dateTimeColor]
        let date = DateFormatter.shortDateFormatter.string(from: nextOccuranceDate)
        let time = DateFormatter.timeFormatter.string(from: nextOccuranceDate)
        let dateString = NSMutableAttributedString(string: NSLocalizedString("\(date) at \(time)", comment: ""))
        let middleCount = dateString.length - date.count - time.count
        dateString.addAttributes(dateTimeAttributes, range: NSRange(location: 0, length: date.count))
        dateString.addAttributes(otherAttributes, range: NSRange(location: date.count, length: middleCount))
        dateString.addAttributes(dateTimeAttributes, range: NSRange(location: date.count + middleCount, length: time.count))

        prefix.append(dateString)

        return prefix
    }

    /// Does not update the following: id, profile, routineTemplate, version, activities.
    static func updateFields(for routine: Routine, from routineTemplate: RoutineTemplate) {
        routine.sunday = routineTemplate.sunday
        routine.monday = routineTemplate.monday
        routine.tuesday = routineTemplate.tuesday
        routine.wednesday = routineTemplate.wednesday
        routine.thursday = routineTemplate.thursday
        routine.friday = routineTemplate.friday
        routine.saturday = routineTemplate.saturday
        routine.endTime = routineTemplate.endTime
        routine.alertStyle = routineTemplate.alertStyle
        routine.reminder = routineTemplate.reminder
    }

    static func sortedRoutineTemplateActivities(from routineTemplateActivities: [RoutineTemplateActivity]) -> [RoutineTemplateActivity] {
        return routineTemplateActivities.sorted { (left, right) -> Bool in
            guard let leftOrder = left.displayOrder, let rightOrder = right.displayOrder else {
                logError()
                return false
            }
            return leftOrder < rightOrder
        }
    }

    static func findRoutine(with routineTemplate: RoutineTemplate?) -> Routine? {
        guard let template = routineTemplate, let id = template.id else {
            logError()
            return nil
        }
        guard let routines = MyWayyService.shared.profile?.routines else {
            logDebug("No routines")
            return nil
        }
        guard let index = routines.index(where: { (thisRoutine) -> Bool in
            guard let thisTemplateId = thisRoutine.routineTemplate else { return false }
            return thisTemplateId == id
        }) else {
            logDebug("No matching routine with template ID \(id)")
            return nil
        }

        return routines[index]
    }

    static func isFullyInitializedRoutineTemplate(_ routineTemplate: RoutineTemplate?) -> Bool {
        guard let template = routineTemplate, let ownersProfileId = template.profile else {
            // Not much we can do without these
            logError()
            return false
        }
        guard template.routineTemplateActivities.count > 0 else {
            logError("No routineTemplateActivities!")
            return false
        }
        guard template.duration() > 0 else {
            logError("Routine template duration is invalid!")
            return false
        }
        guard let currentProfileId = MyWayyService.shared.profile?.id, currentProfileId == ownersProfileId else {
            // If the current user doesn't own this routineTemplate, or if there
            // is no current user, call it good here.
            return true
        }

        // Current user owns this routineTemplate, so make sure we can find a
        // routine associated with it.
        guard let routine = findRoutine(with: template) else {
            logError("Can't find matching routine")
            return false
        }
        return routineHasActivities(routine)
    }

    static func isFullyInitializedRoutine(_ routine: Routine?) -> Bool {
        return routineHasActivities(routine) && isFullyInitializedRoutineTemplate(routine?.getTemplate())
    }

    // MARK: Private

    private static func routineHasActivities(_ routine: Routine?) -> Bool {
        guard let r = routine else {
            logError()
            return false
        }
        guard r.activities.count > 0 else {
            logError("No activities!")
            return false
        }
        guard r.duration() > 0 else {
            logError("Routine duration is invalid!")
            return false
        }
        return true
    }

    /// Returns the next two weeks worth of start dates, at startTime, using weekFlags to determine which days.
    private static func getNextOccurranceDates(for startTime: Date, now: Date, weekFlags: WeekFlags) -> [Date] {
        var dates = [Date]()
        var flags = Set<Calendar.Component>([.year, .month, .day, .weekday])
        let nowComponents = NSCalendar.current.dateComponents(flags, from: now)

        flags = Set<Calendar.Component>([.hour, .minute, .second])
        var startDateComponents = NSCalendar.current.dateComponents(flags, from: startTime)
        startDateComponents.year = nowComponents.year
        startDateComponents.month = nowComponents.month
        startDateComponents.day = nowComponents.day
        guard
            let startDate = Calendar.current.date(from: startDateComponents),
            let todayWeekday = nowComponents.weekday
            else {
                logError()
                return dates
        }

        for baseDayIncrement in [0, OrdinalDay.maxValue] {
            for setWeekday in (weekFlags.setDays.map { $0.rawValue }) {
                var daysToAdd = baseDayIncrement

                if setWeekday >= todayWeekday {
                    daysToAdd += setWeekday - todayWeekday
                } else {
                    daysToAdd += 7 - (todayWeekday - setWeekday)
                }

                var adjustmentComponents = DateComponents()
                adjustmentComponents.day = daysToAdd
                if let date = NSCalendar.current.date(byAdding: adjustmentComponents, to: startDate) {
                    dates.append(date)
                } else {
                    logError("daysToAdd: \(daysToAdd): \(startDate)")
                }
            }
        }

        return dates.sorted()
    }
}
