//
//  Activity.swift
//  MyWayy
//
//  Created by SpinDance on 10/30/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

/*
 * https://github.com/MyWayy/cloud/tree/master/src/api/activity
 */

class Activity {

    var flags: [String: Bool] = [
        // NOTE: The routine field is purposefully not included, since the
        // server does not accept changes to that field.
        "activityTemplate": false,
        "routineTemplateActivity": false,
        "duration": false,
        "acceptedActivityTemplateVersion": false,
        "acceptedRoutineTemplateActivityVersion": false
    ]

    var id: Int?
    var routine: Int?
    var routineTemplateActivity: Int?
    var activityTemplate: Int?

    var duration: Int? {
        willSet {
            flags["duration"] = flags["duration"]! || self.duration != newValue
        }
    }

    var acceptedActivityTemplateVersion: Int?
    var acceptedRoutineTemplateActivityVersion: Int?

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
            } else if field == "routine" {
                self.routine = value as? Int
            } else if field == "activityTemplate" {
                self.activityTemplate = value as? Int
            } else if field == "routineTemplateActivity" {
                self.routineTemplateActivity = value as? Int
            } else if field == "duration" {
                self.duration = value as? Int
            } else if field == "acceptedActivityTemplateVersion" {
                self.acceptedActivityTemplateVersion = value as? Int
            } else if field == "acceptedRoutineTemplateActivityVersion" {
                self.acceptedRoutineTemplateActivityVersion = value as? Int
            }
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
        if field == "routine" {
            accumulator[field] = routine
        } else if field == "activityTemplate" {
            accumulator[field] = activityTemplate
        } else if field == "routineTemplateActivity" {
            accumulator[field] = routineTemplateActivity
        } else if field == "duration" {
            accumulator[field] = duration
        } else if field == "acceptedActivityTemplateVersion" {
            accumulator[field] = acceptedActivityTemplateVersion
        } else if field == "acceptedRoutineTemplateActivityVersion" {
            accumulator[field] = acceptedRoutineTemplateActivityVersion
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

    func toString(_ buffer: inout String, pad: String = "") {
        buffer.append("\(pad)id: \(id ?? -1)\n")
        buffer.append("\(pad)routine: \(routine ?? -1)\n")
        buffer.append("\(pad)routineTemplateActivity: \(routineTemplateActivity ?? -1)\n")
        buffer.append("\(pad)activityTemplate: \(activityTemplate ?? -1)\n")
        buffer.append("\(pad)duration: \(duration ?? -1)\n")
        buffer.append("\(pad)acceptedActivityTemplateVersion: \(acceptedActivityTemplateVersion ?? -1)\n")
        buffer.append("\(pad)acceptedRoutineTemplateActivityVersion: \(acceptedRoutineTemplateActivityVersion ?? -1)\n")
    }
}

// Helper extension for Activity
extension Activity {
    var durationInSeconds: Int? {
        guard let d = duration else {
            return nil
        }
        return d * Constants.secondsInMinute
    }

    func getTemplate() -> ActivityTemplate? {
        guard let id = activityTemplate else {
            print("activityTemplate id is nil!")
            return nil
        }
        guard let template = MyWayyCache.activityTemplate(id) else {
            print("No activityTemplate with id \(id)!")
            return nil
        }
        return template
    }
}
