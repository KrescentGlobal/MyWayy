//
//  RtaProcessor.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/10/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation

/// RoutineTemplateActivity Selection Model
class RtaSelectionModel: NSObject {
    let routineId: Int?
    let routineTemplateId: Int
    let activityTemplateId: Int
    let activityTemplateDuration: Int
    let activityTemplateVersion: Int
    var routineTemplateActivity: RoutineTemplateActivity

    /// routineId can be nil, all other fields must be non-nil. However routineId
    /// must be non-nil when attempting to use generateNewActivity(routineTemplateActivityId:)
    init?(routineId: Int?,
          routineTemplateId: Int?,
          activityTemplateId: Int?,
          activityTemplateDuration: Int?,
          activityTemplateVersion: Int?) {
        guard
            let theRoutineTemplateId = routineTemplateId,
            let theActivityTemplateId = activityTemplateId,
            let theActivityTemplateDuration = activityTemplateDuration,
            let theActivityTemplateVersion = activityTemplateVersion else {
                logError("\(String(describing: routineTemplateId)) \(String(describing: activityTemplateId)) \(String(describing: activityTemplateDuration)) \(String(describing: activityTemplateVersion))")
                return nil
        }
        self.routineId = routineId
        self.routineTemplateId = theRoutineTemplateId
        self.activityTemplateId = theActivityTemplateId
        self.activityTemplateDuration = theActivityTemplateDuration
        self.activityTemplateVersion = theActivityTemplateVersion

        // Create a default routineTemplateActivity. This will be used when create
        // a new RoutineTemplateActivity. Otherwise the routineTemplateActivity
        // field can be overwritten with an instance that is being updated.
        var routineTemplateActivityFields = [String: Any]()
        routineTemplateActivityFields["routineTemplate"] = self.routineTemplateId
        routineTemplateActivityFields["activityTemplate"] = self.activityTemplateId
        routineTemplateActivity = RoutineTemplateActivity(routineTemplateActivityFields)
    }

    func generateNewActivity(routineTemplateActivityId: Int) -> Activity? {
        guard let theRoutineId = routineId else {
            logError("Cannot create activity; routineId is nil! Creating an activity is not necessary for when creating new RoutineTemplateActivities for a new RoutineTemplate!")
            return nil
        }
        let dict: [String: Any] = ["routine": theRoutineId,
                                   "activityTemplate": activityTemplateId,
                                   "routineTemplateActivity": routineTemplateActivityId,
                                   "duration": activityTemplateDuration,
                                   "acceptedActivityTemplateVersion": activityTemplateVersion,
                                   "acceptedRoutineTemplateActivityVersion": routineTemplateActivity.version]
        return Activity(dict)
    }

    static func sort(models: [RtaSelectionModel], accordingTo routineTemplate: RoutineTemplate?) -> [RtaSelectionModel] {
        var sortedModels = [RtaSelectionModel]()

        guard let template = routineTemplate else {
            logError()
            return sortedModels
        }

        for rta in RoutineHelper.sortedRoutineTemplateActivities(from: template.routineTemplateActivities) {
            guard let index = models.index(where: { (model) -> Bool in
                guard let rtaActivityTemplateId = rta.activityTemplate else {
                    return false
                }
                return model.activityTemplateId == rtaActivityTemplateId
            }) else {
                logError("Could not find RtaSelectionModel with RTA ID \(String(describing: rta.id))")
                continue
            }
            sortedModels.append(models[index])
        }

        if sortedModels.count != models.count {
            logError("\(sortedModels.count) doesn't match \(models.count)!")
        }

        return sortedModels
    }
}

/// RoutineTemplateActivity (RTA) processor - a helper type for processing lists of RTAs
struct RtaProcessor {
    let rtasToDelete: [RoutineTemplateActivity]
    let rtaSelections: [RtaSelectionModel]

    init(oldRtas: [RoutineTemplateActivity]?, selections: [RtaSelectionModel]) {
        var deleteList = [RoutineTemplateActivity]()
        var oldIndicesToKeep = [Int]()

        // If no oldRtas are specified, this implies that newRtas are truly all new ones
        guard let old = oldRtas, !old.isEmpty else {
            rtasToDelete = deleteList
            rtaSelections = selections
            return
        }
        var newSelectionList = [RtaSelectionModel]()

        // For each new RTA, determine if it already exists. If so, we're
        // just updating that one. Else, we have to create it.
        for selection in selections {
            if let index = old.index(where: { (oldRta) -> Bool in
                oldRta.activityTemplate != nil && oldRta.activityTemplate! == selection.activityTemplateId
            }) {
                // Add the matching oldRta to newList, since it's in newRtas (it already exists.)
                selection.routineTemplateActivity = old[index]
                newSelectionList.append(selection)
                oldIndicesToKeep.append(index)
            } else {
                // The newRta doesn't exist in the old list, so it truly is new. Add it to our list.
                newSelectionList.append(selection)
            }
        }

        // Determine which RTAs need to be deleted. Delete them if they're not in oldIndicesToKeep
        for (index, template) in old.enumerated() {
            if !oldIndicesToKeep.contains(where: { (oldIndex) -> Bool in
                index == oldIndex
            }) {
                deleteList.append(template)
            }
        }

        rtasToDelete = deleteList
        rtaSelections = newSelectionList
    }
}
