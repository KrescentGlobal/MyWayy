//
//  Routine.swift
//  MyWayy
//
//  Created by SpinDance on 10/30/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

/*
 * https://github.com/MyWayy/cloud/blob/master/src/api/routineTemplate/README.md
 */

class Routine: WeekFlagsOwner {

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    var flags: [String: Bool] = [
        "routineTemplate": false,
        "endTime": false,
        "sunday": false,
        "monday": false,
        "tuesday": false,
        "wednesday": false,
        "thursday": false,
        "friday": false,
        "saturday": false,
        "alertStyle": false,
        "reminder": false,
        "version": false
    ]

    var id: Int?
    var profile: Int?
    var routineTemplate: Int?

    var endTime: String? {
        willSet {
            flags["endTime"] = flags["endTime"]! || self.endTime != newValue
            version = flags["endTime"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var sunday: Bool? {
        willSet {
            flags["sunday"] = flags["sunday"]! || self.sunday != newValue
            version = flags["sunday"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var monday: Bool? {
        willSet {
            flags["monday"] = flags["monday"]! || self.monday != newValue
            version = flags["monday"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var tuesday: Bool? {
        willSet {
            flags["tuesday"] = flags["tuesday"]! || self.tuesday != newValue
            version = flags["tuesday"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var wednesday: Bool? {
        willSet {
            flags["wednesday"] = flags["wednesday"]! || self.wednesday != newValue
            version = flags["wednesday"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var thursday: Bool? {
        willSet {
            flags["thursday"] = flags["thursday"]! || self.thursday != newValue
            version = flags["thursday"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var friday: Bool? {
        willSet {
            flags["friday"] = flags["friday"]! || self.friday != newValue
            version = flags["friday"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var saturday: Bool? {
        willSet {
            flags["saturday"] = flags["saturday"]! || self.saturday != newValue
            version = flags["saturday"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var alertStyle: String? {
        willSet {
            flags["alertStyle"] = flags["alertStyle"]! || self.alertStyle != newValue
            version = flags["alertStyle"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var reminder: String? {
        willSet {
            flags["reminder"] = flags["reminder"]! || self.reminder != newValue
            version = flags["reminder"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var version = 1 {
        willSet {
            flags["version"] = flags["version"]! || self.version != newValue
        }
    }

    var activities = [Activity]()

    init(_ fields: [String: Any], updated: Bool = false) {
        set(fields: fields)

        if !updated {
            clearUpdates()
        }
    }

    func set(fields: [String: Any]) {
        fields.forEach({ (value) in
            let (field, value) = value

            if field == "id" {
                self.id = value as? Int
            } else if field == "profile" {
                self.profile = value as? Int
            } else if field == "routineTemplate" {
                self.routineTemplate = value as? Int
            } else if field == "endTime" {
                self.endTime = value as? String
            } else if field == "sunday" {
                self.sunday = value as? Bool
            } else if field == "monday" {
                self.monday = value as? Bool
            } else if field == "tuesday" {
                self.tuesday = value as? Bool
            } else if field == "wednesday" {
                self.wednesday = value as? Bool
            } else if field == "thursday" {
                self.thursday = value as? Bool
            } else if field == "friday" {
                self.friday = value as? Bool
            } else if field == "saturday" {
                self.saturday = value as? Bool
            } else if field == "alertStyle" {
                self.alertStyle = value as? String
            } else if field == "reminder" {
                self.reminder = value as? String
            } else if field == "version" {
                self.version = value as! Int
            } else if field == "activities" {
                if let array = value as? [[String: Any]] {
                    setActivities(array)
                }
            }
        })
    }

    func setActivities(_ array: [[String: Any]]) {
        activities.removeAll()
        array.forEach({ (fields) in
            let activity = MyWayyCache.activity(fields["id"] as? Int, {
                return Activity(fields)
            })!
            activity.set(fields: fields)
            activities.append(activity)
        })
    }

    func updates() -> [String: Any] {
        var accumulator = [String: Any]()

        flags.forEach({ (value) in
            let (field, _) = value
            insert(accumulator: &accumulator, field: field)
        })

        return accumulator
    }

    func insert(accumulator: inout [String: Any], field: String) {
        if field == "routineTemplate" {
            accumulator[field] = routineTemplate
        } else if field == "endTime" {
            accumulator[field] = endTime
        } else if field == "sunday" {
            accumulator[field] = sunday
        } else if field == "monday" {
            accumulator[field] = monday
        } else if field == "tuesday" {
            accumulator[field] = tuesday
        } else if field == "wednesday" {
            accumulator[field] = wednesday
        } else if field == "thursday" {
            accumulator[field] = thursday
        } else if field == "friday" {
            accumulator[field] = friday
        } else if field == "saturday" {
            accumulator[field] = saturday
        } else if field == "alertStyle" {
            accumulator[field] = alertStyle
        } else if field == "reminder" {
            accumulator[field] = reminder
        } else if field == "version" {
            accumulator[field] = version
        }
    }

    func clearUpdates() {
        flags.forEach({ (value) in
            let (field, _) = value
            flags[field] = false
        })
    }

    func hasUpdates() -> Bool {
        return flags.reduce(false, { (accumulator, value) in
            let (_, flag) = value
            return accumulator || flag
        })
    }

    func duration() -> Int {
        return activities.reduce(0, { (a, activity) in
            return a + activity.duration!
        })
    }

    func endTimeAsDate() -> Date? {
        let endTimeString = endTime ?? getTemplate()?.endTime

        guard let string = endTimeString else {
            logError("No end time")
            return nil
        }

        return Routine.dateFormatter.date(from: string)
    }

    func toString(_ buffer: inout String, pad: String = "") {
        buffer.append("\(pad)id: \(id ?? -1)\n")
        buffer.append("\(pad)profile: \(profile ?? -1)\n")
        buffer.append("\(pad)routineTemplate: \(routineTemplate ?? -1)\n")
        buffer.append("\(pad)endTime: \(endTime ?? "")\n")
        buffer.append("\(pad)sunday: \(sunday ?? false)\n")
        buffer.append("\(pad)monday: \(monday ?? false)\n")
        buffer.append("\(pad)tuesday: \(tuesday ?? false)\n")
        buffer.append("\(pad)wednesday: \(wednesday ?? false)\n")
        buffer.append("\(pad)thursday: \(thursday ?? false)\n")
        buffer.append("\(pad)friday: \(friday ?? false)\n")
        buffer.append("\(pad)saturday: \(saturday ?? false)\n")
        buffer.append("\(pad)alertStyle: \(alertStyle ?? "")\n")
        buffer.append("\(pad)reminder: \(reminder ?? "")\n")
        buffer.append("\(pad)version: \(version)\n")
        buffer.append("\(pad)activities:\n")
        activities.forEach({ (n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
    }
}

/// Helper extension for Routine
extension Routine {
    var durationInSeconds: Int {
        return duration() * Constants.secondsInMinute
    }

    func getTemplate() -> RoutineTemplate? {
        guard let id = routineTemplate else {
            print("routineTemplate id is nil!")
            return nil
        }
        guard let template = MyWayyCache.routineTemplate(id) else {
            print("No routineTemplate with id \(id)!")
            return nil
        }
        return template
    }

    func getAlertStyle() -> AlertStyle {
        let defaultStyle = AlertStyle.none

        guard let string = alertStyle else {
            logError("'alertStyle' is nil")
            return defaultStyle
        }
        guard let style = AlertStyle(rawValue: string) else {
            logError("Invalid value for 'alertStyle': \(string)")
            return defaultStyle
        }

        return style
    }

    func getNextScheduledDate() -> Date? {
        guard let endDate = endTimeAsDate() else {
            logError()
            return nil
        }
        return RoutineHelper.getNextScheduledDate(from: endDate, durationMinutes: duration(), weekFlags: WeekFlags.from(self))
    }

    func hasActivity(with activityTemplateId: Int?) -> Bool {
        guard let targetTemplateId = activityTemplateId else {
            return false
        }

        return nil != activities.index(where: { (activity) -> Bool in
            guard let templateId = activity.activityTemplate else { return false }
            return templateId == targetTemplateId
        })
    }

    func sortedActivities() -> [Activity] {
        guard let template = getTemplate() else {
            logError()
            return activities
        }

        // Now sort activities according to the sorted RTAs
        var sortedActivities = [Activity]()
        for rta in RoutineHelper.sortedRoutineTemplateActivities(from: template.routineTemplateActivities) {
            guard let index = activities.index(where: { (activity) -> Bool in
                guard let targetId = rta.activityTemplate, let thisId = activity.activityTemplate else {
                    logError()
                    return false
                }
                return targetId == thisId
            }) else {
                logError()
                continue
            }
            sortedActivities.append(activities[index])
        }

        if activities.count != sortedActivities.count {
            logError("\(activities.count) doesn't match \(sortedActivities.count)!")
        }
        return sortedActivities
    }
}
