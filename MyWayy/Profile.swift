//
//  Profile.swift
//  MyWayy
//
//  Created by SpinDance on 10/18/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

/*
 * https://github.com/MyWayy/cloud/blob/master/src/api/profile/README.md
 */

class Profile {

    var flags: [String: Bool] = [
        "username": false,
        "name": false,
        "phoneNumber": false,
        "email": false,
        "image": false,
        "totalRoutineMinutes": false,
        "description" : false,
        "interest" : false
    ]

    var id: Int?
    var cognitoIdentityId: String?

    var username: String? {
        willSet {
            flags["username"] = flags["username"]! || self.username != newValue
        }
    }

    var name: String? {
        willSet {
            flags["name"] = flags["name"]! || self.name != newValue
        }
    }

    var phoneNumber: String? {
        willSet {
            flags["phoneNumber"] = flags["phoneNumber"]! || self.phoneNumber != newValue
        }
    }

    var email: String? {
        willSet {
            flags["email"] = flags["email"]! || self.email != newValue
        }
    }

    var image: String? {
        willSet {
            flags["image"] = flags["image"]! || self.image != newValue
        }
    }

    var totalRoutineMinutes: Int? {
        willSet {
            flags["totalRoutineMinutes"] = flags["totalRoutineMinutes"]! || self.totalRoutineMinutes != newValue
        }
    }
    
    var description: String? {
        willSet {
            flags["description"] = flags["description"]! || self.description != newValue
        }
    }
    var interest: String? {
        willSet {
            flags["interest"] = flags["interest"]! || self.interest != newValue
        }
    }
    var routineTemplates = [RoutineTemplate]()
    var activityTemplates = [ActivityTemplate]()
    var routines = [Routine]()

    init(_ fields: [String: Any], updated: Bool = false) {
        set(fields: fields)

        if !updated {
            clearUpdates()
        }
    }

    func set(fields: [String: Any]) {
        fields.forEach({ (pair) in
            let (field, value) = pair

            if field == "id" {
                id = value as? Int
            } else if field == "cognitoIdentityId" {
                cognitoIdentityId = value as? String
            } else if field == "username" {
                username = value as? String
            } else if field == "name" {
                name = value as? String
            } else if field == "phoneNumber" {
                phoneNumber = value as? String
            } else if field == "email" {
                email = value as? String
            } else if field == "image" {
                image = value as? String
            } else if field == "totalRoutineMinutes" {
                totalRoutineMinutes = value as? Int
            }else if field == "description" {
                description = value as? String
            }else if field == "interest" {
                interest = value as? String
            }else if field == "routineTemplates" {
                if let array = value as? [[String: Any]] {
                    setRoutineTemplates(array)
                }
            } else if field == "activityTemplates" {
                if let array = value as? [[String: Any]] {
                    setActivityTemplates(array)
                }
            } else if field == "routines" {
                if let array = value as? [[String: Any]] {
                    setRoutines(array)
                }
            }
        })
    }

    func setRoutineTemplates(_ array: [[String: Any]]) {
        routineTemplates.removeAll()
        array.forEach({ (fields) in
            let routineTemplate = MyWayyCache.routineTemplate(fields["id"] as? Int, {
                return RoutineTemplate(fields)
            })!

            routineTemplate.set(fields: fields)
            routineTemplates.append(routineTemplate)
        })
    }

    func setActivityTemplates(_ array: [[String: Any]]) {
        activityTemplates.removeAll()
        array.forEach({ (fields) in
            let activityTemplate = MyWayyCache.activityTemplate(fields["id"] as? Int, {
                return ActivityTemplate(fields)
            })!
            activityTemplate.set(fields: fields)
            activityTemplates.append(activityTemplate)
        })
    }

    func setRoutines(_ array: [[String: Any]]) {
        routines.removeAll()
        array.forEach({ (fields) in
            routines.append(Routine(fields))
        })
    }

    func getRoutineTemplateById(_ id: Int) -> RoutineTemplate? {
        for (_, n) in routineTemplates.enumerated() {
            if n.id == id {
                return n
            }
        }

        return nil
    }
    
    func removeRoutineTemplateById(_ id: Int) {
        var index_ = 0
        for (_, n) in routineTemplates.enumerated() {
            if n.id == id {
                routineTemplates.remove(at: index_)
            }
             index_ = index_+1
        }
    }

    func getActivityTemplateById(_ id: Int) -> ActivityTemplate? {
        for (_, n) in activityTemplates.enumerated() {
            if n.id == id {
                return n
            }
        }

        return nil
    }
    
    
    func removeActivityTemplateById(_ id: Int){
        var index_ = 0
        for(_, n) in activityTemplates.enumerated(){
            if n.id == id{
                activityTemplates.remove(at: index_)
            }
            index_ = index_+1
        }
        
    }
    

    func getRoutineById(_ id: Int) -> Routine? {
        for (_, n) in routines.enumerated() {
            if n.id == id {
                return n
            }
        }

        return nil
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
        if field == "username" {
            accumulator[field] = username
        } else if field == "name" {
                accumulator[field] = name
        } else if field == "phoneNumber" {
            accumulator[field] = phoneNumber
        } else if field == "email" {
            accumulator[field] = email
        } else if field == "image" {
            accumulator[field] = image
        } else if field == "totalRoutineMinutes" {
            accumulator[field] = totalRoutineMinutes
        }
        else if field == "description" {
            accumulator[field] = description
        }
        else if field == "interest" {
            accumulator[field] = interest
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
        buffer.append("\(pad)cognitoIdentityId: \(cognitoIdentityId ?? "nil")\n")
        buffer.append("\(pad)username: \(username ?? "nil")\n")
        buffer.append("\(pad)name: \(name ?? "nil")\n")
        buffer.append("\(pad)phoneNumber: \(phoneNumber ?? "nil")\n")
        buffer.append("\(pad)email: \(email ?? "nil")\n")
        buffer.append("\(pad)totalRoutineMinutes: \(totalRoutineMinutes ?? -1)\n")
        buffer.append("\(pad)description: \(description ?? "nil")\n")
        buffer.append("\(pad)interest: \(interest ?? "nil")\n")
        buffer.append("\(pad)routineTemplates:\n")
        routineTemplates.forEach({ (n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
        buffer.append("\(pad)activityTemplates:\n")
        activityTemplates.forEach({ (n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
        buffer.append("\(pad)routines:\n")
        routines.forEach({ (n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
    }

    func isSubscribed(to routineTemplateId: Int?) -> Bool {
        guard let id = routineTemplateId else { return false }

        for routine in routines {
            guard let thisTemplateId = routine.routineTemplate else {
                logError()
                continue
            }
            guard id != thisTemplateId else {
                // match found
                return true
            }
        }

        return false
    }
}
