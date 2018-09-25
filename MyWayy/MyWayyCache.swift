//
//  MyWayyCache.swift
//  MyWayy
//
//  Created by SpinDance on 11/2/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

class MyWayyCache {
    static var shared = MyWayyCache()

    var profiles = [Int: Profile]()
    var routineTemplates = [Int: RoutineTemplate]()
    var routineTemplateActivities = [Int: RoutineTemplateActivity]()
    var activityTemplates = [Int: ActivityTemplate]()
    var routines = [Int: Routine]()
    var activities = [Int: Activity]()

    static func invalidate() {
        MyWayyCache.shared = MyWayyCache()
    }

    // MARK: profiles

    static func profile(_ id: Int?, _ initializer: (() -> Profile?)? = nil) -> Profile? {
        if let key = id {
            if let item = shared.profiles[key] {
                return item
            } else if let item = initializer?() {
                profile(item)
                return item
            }
        }
        
        print("MyWayyCache.profile.W: miss (\(id ?? -1))")
        return nil
    }

    static func profile(_ profile: Profile) {
        if let key = profile.id {
            shared.profiles[key] = profile
        } else {
            print("MyWayyCache.proflile.W: key == nil")
        }
    }

    // MARK: routineTemplates

    static func routineTemplate(_ id: Int?, _ initializer: (() -> RoutineTemplate?)? = nil) -> RoutineTemplate? {
        if let key = id {
            if let item = shared.routineTemplates[key] {
                return item
            } else if let item = initializer?() {
                routineTemplate(item)
                return item
            }
        }
        
        print("MyWayyCache.routineTemplates.W: miss (\(id ?? -1))")
        return nil
    }

    static func routineTemplate(_ routineTemplate: RoutineTemplate) {
        if let key = routineTemplate.id {
            shared.routineTemplates[key] = routineTemplate
        } else {
            print("MyWayyCache.routineTemplate.W: key == nil")
        }
    }

    // MARK: routineTemplateActivities

    static func routineTemplateActivity(_ id: Int?, _ initializer: (() -> RoutineTemplateActivity?)? = nil) -> RoutineTemplateActivity? {
        if let key = id {
            if let item = shared.routineTemplateActivities[key] {
                return item
            } else if let item = initializer?() {
                routineTemplateActivity(item)
                return item
            }
        }
        
        print("MyWayyCache.routineTemplateActivities.W: miss (\(id ?? -1))")
        return nil
    }

    static func routineTemplateActivity(_ routineTemplateActivity: RoutineTemplateActivity) {
        if let key = routineTemplateActivity.id {
            shared.routineTemplateActivities[key] = routineTemplateActivity
        } else {
            print("MyWayyCache.routineTemplateActivity.W: key == nil")
        }
    }

    // MARK: activityTemplates
    
    static func activityTemplate(_ id: Int?, _ initializer: (() -> ActivityTemplate?)? = nil) -> ActivityTemplate? {
        if let key = id {
            if let item = shared.activityTemplates[key] {
                return item
            } else if let item = initializer?() {
                activityTemplate(item)
                return item
            }
        }
        
        print("MyWayyCache.activityTemplate.W: miss (\(id ?? -1))")
        return nil
    }
    
    static func removeActivityTemplate() {
            shared.activityTemplates.removeAll()
        
    }

    static func activityTemplate(_ activityTemplate: ActivityTemplate) {
        if let key = activityTemplate.id {
            shared.activityTemplates[key] = activityTemplate
            
           
        } else {
            print("MyWayyCache.activityTemplate.W: key == nil")
        }
    }

    // MARK: routine

    static func routine(_ id: Int?, _ initializer: (() -> Routine?)? = nil) -> Routine? {
        if let key = id {
            if let item = shared.routines[key] {
                return item
            } else if let item = initializer?() {
                routine(item)
                return item
            }
        }
        
        print("MyWayyCache.routine.W: miss (\(id ?? -1))")
        return nil
    }

    static func routine(_ routine: Routine) {
        if let key = routine.id {
            shared.routines[key] = routine
        } else {
            print("MyWayyCache.routine.W: key == nil")
        }
    }

    // MARK: activity
    
    static func activity(_ id: Int?, _ initializer: (() -> Activity?)? = nil) -> Activity? {
        if let key = id {
            if let item = shared.activities[key] {
                return item
            } else if let item = initializer?() {
                activity(item)
                return item
            }
        }
        
        print("MyWayyCache.routine.W: miss (\(id ?? -1))")
        return nil
    }

    static func activity(_ activity: Activity) {
        if let key = activity.id {
            shared.activities[key] = activity
        } else {
            print("MyWayyCache.activity.W: key == nil")
        }
    }

    // MARK: tags

    static func tags() -> [String] {
        var tags = [String]()

        shared.routineTemplates.values.forEach({ (template) in
            if template.tags != nil && template.tags != "" {
                tags.append(template.tags!)
            }
        })

        shared.activityTemplates.values.forEach({ (template) in
            if template.tags != nil && template.tags != "" {
                tags.append(template.tags!)
            }
        })

        return Array(Set(tags))
    }

    // MARK: toString

    static func toString(_ buffer: inout String, pad: String = "") {
        buffer.append("\(pad)profiles:\n")
        shared.profiles.forEach({ (_, n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
        buffer.append("\(pad)routineTemplates:\n")
        shared.routineTemplates.forEach({ (_, n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
        buffer.append("\(pad)routineTemplateActivities:\n")
        shared.routineTemplateActivities.forEach({ (_, n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
        buffer.append("\(pad)activityTemplates:\n")
        shared.activityTemplates.forEach({ (_, n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
        buffer.append("\(pad)routines:\n")
        shared.routines.forEach({ (_, n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
        buffer.append("\(pad)activities:\n")
        shared.activities.forEach({ (_, n) in
            buffer.append("\(pad){\n")
            n.toString(&buffer, pad: "\(pad)    ")
            buffer.append("\(pad)}\n")
        })
    }
}
