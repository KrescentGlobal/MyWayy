//
//  RoutineTemplateActivity.swift
//  MyWayy
//
//  Created by SpinDance on 10/30/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

/*
 * https://github.com/MyWayy/cloud/tree/master/src/api/routineTemplateActivity
 */

class RoutineTemplateActivity {

    var flags: [String: Bool] = [
        "activityTemplate": false,
        "displayOrder": false,
        "version": false
    ]

    var id: Int?
    var routineTemplate: Int?

    var activityTemplate: Int? {
        willSet {
            flags["activityTemplate"] = flags["activityTemplate"]! || self.activityTemplate != newValue
            version = flags["activityTemplate"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var displayOrder: Int? {
        willSet {
            flags["displayOrder"] = flags["displayOrder"]! || self.displayOrder != newValue
            version = flags["displayOrder"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var version = 1 {
        willSet {
            flags["version"] = flags["version"]! || self.version != newValue
        }
    }

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
            } else if field == "routineTemplate" {
                self.routineTemplate = value as? Int
            } else if field == "activityTemplate" {
                self.activityTemplate = value as? Int
            } else if field == "displayOrder" {
                self.displayOrder = value as? Int
            } else if field == "version" {
                self.version = value as! Int
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
        if field == "activityTemplate" {
            accumulator[field] = activityTemplate
        } else if field == "displayOrder" {
            accumulator[field] = displayOrder
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

    func toString(_ buffer: inout String, pad: String = "") {
        buffer.append("\(pad)id: \(id ?? -1)\n")
        buffer.append("\(pad)routineTemplate: \(routineTemplate ?? -1)\n")
        buffer.append("\(pad)activityTemplate: \(activityTemplate ?? -1)\n")
        buffer.append("\(pad)displayOrder: \(displayOrder ?? -1)\n")
        buffer.append("\(pad)version: \(version)\n")
    }
}
