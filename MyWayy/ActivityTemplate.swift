//
//  ActivityTemplate.swift
//  MyWayy
//
//  Created by SpinDance on 10/25/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation
class ActivityTemplate {

    var flags: [String: Bool] = [
        "name": false,
        "description": false,
        "tags": false,
        "icon": false,
        "duration": false,
        "version": false
    ]

    var id: Int?
    var profile: Int?

    var name: String? {
        willSet {
            flags["name"] = flags["name"]! || self.name != newValue
            version = flags["name"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var description: String? {
        willSet {
            flags["description"] = flags["description"]! || self.description != newValue
            version = flags["description"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var tags: String? {
        willSet {
            flags["tags"] = flags["tags"]! || self.tags != newValue
            version = flags["tags"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var icon: String? {
        willSet {
            flags["icon"] = flags["icon"]! || self.icon != newValue
            version = flags["icon"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var duration: Int? {
        willSet {
            flags["duration"] = flags["duration"]! || self.duration != newValue
            version = flags["duration"]! && !flags["version"]! ? version + 1 : version
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
                id = value as? Int
            } else if field == "profile" {
                profile = value as? Int
            } else if field == "name" {
                name = value as? String
            } else if field == "description" {
                description = value as? String
            } else if field == "tags" {
                tags = value as? String
            } else if field == "icon" {
                icon = value as? String
            } else if field == "duration" {
                duration = value as? Int
            } else if field == "version" {
                version = value as! Int
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
        if field == "name" {
            accumulator[field] = name
        } else if field == "description" {
            accumulator[field] = description
        } else if field == "tags" {
            accumulator[field] = tags
        } else if field == "icon" {
            accumulator[field] = icon
        } else if field == "duration" {
            accumulator[field] = duration
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
        buffer.append("\(pad)profile: \(profile ?? -1)\n")
        buffer.append("\(pad)name: \(name ?? "nil")\n")
        buffer.append("\(pad)description: \(description ?? "nil")\n")
        buffer.append("\(pad)tags: \(tags ?? "nil")\n")
        buffer.append("\(pad)icon: \(icon ?? "nil")\n")
        buffer.append("\(pad)duration: \(duration ?? -1)\n")
        buffer.append("\(pad)version: \(version)\n")
    }
}
