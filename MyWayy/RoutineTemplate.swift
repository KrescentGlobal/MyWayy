//
//  RoutineTemplate.swift
//  MyWayy
//
//  Created by SpinDance on 10/24/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

/*
 * https://github.com/MyWayy/cloud/blob/master/src/api/routineTemplate/README.md
 */

class RoutineTemplate: WeekFlagsOwner {

    static let EndTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:00"
        return formatter
    }()

    var flags: [String: Bool] = [
        "name": false,
        "description": false,
        "tags": false,
        "image": false,
        "isPublic": false,
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

    var image: String? {
        willSet {
            flags["image"] = flags["image"]! || self.image != newValue
            version = flags["image"]! && !flags["version"]! ? version + 1 : version
        }
    }

    var isPublic: Bool? {
        willSet {
            flags["isPublic"] = flags["isPublic"]! || self.isPublic != newValue
            version = flags["isPublic"]! && !flags["version"]! ? version + 1 : version
        }
    }

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

    var routineTemplateActivities = [RoutineTemplateActivity]()

    init(_ fields: [String: Any], updated: Bool = false) {
        set(fields: fields)
        
        if !updated {
            clearUpdates()
        }
    }

    func maybeIncrementVersion() {
        if let alreadyUpdated = flags["version"], !alreadyUpdated {
            version += 1
        }
    }

    func set(fields: [String: Any]) {
        fields.forEach({ (value) in
            let (field, value) = value
            
            if field == "id" {
                self.id = value as? Int
            } else if field == "profile" {
                self.profile = value as? Int
            } else if field == "name" {
                self.name = value as? String
            } else if field == "description" {
                self.description = value as? String
            } else if field == "tags" {
                self.tags = value as? String
            } else if field == "image" {
                self.image = value as? String
            } else if field == "isPublic" {
                self.isPublic = value as? Bool
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
            } else if field == "routineTemplateActivities" {
                if let array = value as? [[String: Any]] {
                    setRoutineTemplateActivities(array)
                }
            }
        })
    }

    func setRoutineTemplateActivities(_ array: [[String: Any]]) {
        routineTemplateActivities.removeAll()
        array.forEach({ (fields) in
            var routineTemplateActivityFields = [String: Any]()
            var activityTemplateFields = [String: Any]()

            // sort relevant fields into their respective dictionaries
            fields.forEach({ (pair) in
                if pair.key == "id" {
                    routineTemplateActivityFields[pair.key] = pair.value
                } else if pair.key == "routineTemplate" {
                    routineTemplateActivityFields[pair.key] = pair.value
                } else if pair.key == "displayOrder" {
                    routineTemplateActivityFields[pair.key] = pair.value
                } else if pair.key == "version" {
                    routineTemplateActivityFields[pair.key] = pair.value
                } else if pair.key == "activityTemplate" {
                    routineTemplateActivityFields[pair.key] = pair.value
                    activityTemplateFields["id"] = pair.value
                } else if pair.key == "profile" {
                    activityTemplateFields[pair.key] = pair.value
                } else if pair.key == "name" {
                    activityTemplateFields[pair.key] = pair.value
                } else if pair.key == "description" {
                    activityTemplateFields[pair.key] = pair.value
                } else if pair.key == "tags" {
                    activityTemplateFields[pair.key] = pair.value
                } else if pair.key == "icon" {
                    activityTemplateFields[pair.key] = pair.value
                } else if pair.key == "duration" {
                    activityTemplateFields[pair.key] = pair.value
                }
            })

            let routineTemplateActivity = MyWayyCache.routineTemplateActivity(routineTemplateActivityFields["id"] as? Int, {
                return RoutineTemplateActivity(routineTemplateActivityFields)
            })!
            routineTemplateActivity.set(fields: routineTemplateActivityFields)
            routineTemplateActivities.append(routineTemplateActivity)

            let activityTemplate = MyWayyCache.activityTemplate(activityTemplateFields["id"] as? Int, {
                return ActivityTemplate(activityTemplateFields)
            })!
            activityTemplate.set(fields: activityTemplateFields)
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
        } else if field == "image" {
            accumulator[field] = image
        } else if field == "isPublic" {
            accumulator[field] = isPublic
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

    func toString(_ buffer: inout String, pad: String = "") {
        buffer.append("\(pad)id: \(id ?? -1)\n")
        buffer.append("\(pad)profile: \(profile ?? -1)\n")
        buffer.append("\(pad)name: \(name ?? "nil")\n")
        buffer.append("\(pad)description: \(description ?? "nil")\n")
        buffer.append("\(pad)tags: \(tags ?? "nil")\n")
        buffer.append("\(pad)image: \(image ?? "nil")\n")
        buffer.append("\(pad)isPublic: \(isPublic ?? false)\n")
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
        buffer.append("\(pad)routineTemplateActivities:\n")
        routineTemplateActivities.forEach({ (n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
    }
}

/// Helper extension for RoutineTemplate
extension RoutineTemplate {
    func getProfile() -> Profile? {
        guard let id = profile else {
            print("RoutineTemplate '\(String(describing: name))' has no profile id")
            return nil
        }
        guard let profile = MyWayyCache.profile(id) else {
            print("No user/profile with id \(id) for RoutineTemplate '\(String(describing: name))'")
            return nil
        }
        return profile
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

    func endTimeAsDate() -> Date? {
        guard let string = endTime else {
            logError("No end time")
            return nil
        }

        return RoutineTemplate.EndTimeFormat.date(from: string)
    }

    func duration() -> Int {
        let activityTemplates = routineTemplateActivities.map {
            return MyWayyCache.activityTemplate($0.activityTemplate)
        }
        logDebug("\(activityTemplates.count) activityTemplates")
        return activityTemplates.reduce(0, { (a, template) in
            guard let thisTemplate = template else { logError(); return 0 }
            return a + thisTemplate.duration!
        })
    }

    func sortedActivityTemplates() -> [ActivityTemplate] {
        var sortedActivitiesTemplates = [ActivityTemplate]()
        for rta in RoutineHelper.sortedRoutineTemplateActivities(from: routineTemplateActivities) {
            guard let activityTemplate = MyWayyCache.activityTemplate(rta.activityTemplate) else {
                logError()
                continue
            }
            sortedActivitiesTemplates.append(activityTemplate)
        }

        if sortedActivitiesTemplates.count != routineTemplateActivities.count {
            logError("\(sortedActivitiesTemplates.count) doesn't match \(routineTemplateActivities.count)!")
        }

        return sortedActivitiesTemplates
    }
}
