//
//  PublicRoutineViewModel.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/2/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation

struct PublicActivityViewModel {
    var duration = 0
    var name: String?
    var iconName: String?
}

struct PublicRoutineViewModel {
    let duration: Int
    let isSubscribed: Bool
    let activities: [PublicActivityViewModel]
    let alertStyle: AlertStyle
    let name: String?
    let description: String?
    let reminder: String?
    let tags: String?
    let endDate: Date?
    let templateOwnerProfile: Profile?
    let weekFlags: WeekFlags?
    let routineId: Int?
    let routineTemplateId: Int?

    static func from(routineTemplate: RoutineTemplate) -> PublicRoutineViewModel {
        let isSubscribed = MyWayyService.shared.profile?.isSubscribed(to: routineTemplate.id) ?? false
        let activities = routineTemplate.sortedActivityTemplates().map {
            PublicActivityViewModel(duration: $0.duration ?? 0,
                                    name: $0.name,
                                    iconName: $0.icon)
        }

        return PublicRoutineViewModel(duration: routineTemplate.duration(),
                                      isSubscribed: isSubscribed,
                                      activities: activities,
                                      alertStyle: routineTemplate.getAlertStyle(),
                                      name: routineTemplate.name,
                                      description: routineTemplate.description,
                                      reminder: routineTemplate.reminder,
                                      tags: routineTemplate.tags,
                                      endDate: routineTemplate.endTimeAsDate(),
                                      templateOwnerProfile: MyWayyCache.profile(routineTemplate.profile),
                                      weekFlags: WeekFlags.from(routineTemplate),
                                      routineId: nil,
                                      routineTemplateId: routineTemplate.id)
    }

    static func from(routine: Routine) -> PublicRoutineViewModel {
        let activities = routine.sortedActivities().map {
            return PublicActivityViewModel(duration: $0.duration ?? 0,
                                           name: $0.getTemplate()?.name,
                                           iconName: $0.getTemplate()?.icon)
        }

        return PublicRoutineViewModel(duration: routine.duration(),
                                      isSubscribed: true,
                                      activities: activities,
                                      alertStyle: routine.getAlertStyle(),
                                      name: routine.getTemplate()?.name,
                                      description: routine.getTemplate()?.description,
                                      reminder: routine.reminder,
                                      tags: routine.getTemplate()?.tags,
                                      endDate: routine.endTimeAsDate(),
                                      templateOwnerProfile: MyWayyCache.profile(routine.getTemplate()?.profile),
                                      weekFlags: WeekFlags.from(routine),
                                      routineId: routine.id,
                                      routineTemplateId: nil)
    }
}
