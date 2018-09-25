//
//  UserDefaults+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/5/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

/*
 * Information pertaining to a given routine is stored as a dictionary accessed
 * by the routine's ID as a key.
 *
 * "latestCompletionDelta" is the time delta in seconds for the last time the
 * routine was completed. If the routine was completed early, the delta will be
 * negative, if on time, zero, and if late, positive.
 *
 * "backgroundedTime" is the time (Date) at which the app is sent to the
 * background while a routine is active. This time can be used to update the
 * time remaining in the routine and its activities.
 */

import Foundation

extension UserDefaults {

    // MARK: Private Constants

    private struct Keys {
        static let latestCompletionDelta = "doneDelta"
        static let backgroundedTime = "backgroundedTime"
    }

    // MARK: Public Methods

    static func getLatestCompletionDelta(for routineId: Int?) -> Int? {
        guard let value = getRoutineDictionary(for: routineId)?[Keys.latestCompletionDelta] as? Int else {
            logError()
            return nil
        }
        return value
    }

    static func set(latestCompletionDelta: Int, for routineId: Int?) {
        guard var dict = getRoutineDictionary(for: routineId) else {
            logError()
            return
        }
        logDebug("Setting '\(Keys.latestCompletionDelta)' to \(latestCompletionDelta) for routine ID \(String(describing: routineId))")
        dict[Keys.latestCompletionDelta] = latestCompletionDelta
        set(routineDictionary: dict, routineId: routineId)
    }

    static func getBackgroundedTime(for routineId: Int?) -> Date? {
        guard let time = getRoutineDictionary(for: routineId)?[Keys.backgroundedTime] as? Date else {
            logError()
            return nil
        }
        return time
    }

    static func set(backgroundedTime: Date, for routineId: Int?) {
        guard var dict = getRoutineDictionary(for: routineId) else {
            logError()
            return
        }
        dict[Keys.backgroundedTime] = backgroundedTime
        set(routineDictionary: dict, routineId: routineId)
    }

    // MARK: Private Methods

    private static func getRoutineDictionary(for routineId: Int?) -> [String : Any]? {
        guard let id = routineId else {
            logError()
            return nil
        }
        return UserDefaults.standard.dictionary(forKey: String(id)) ?? [String: Any]()
    }

    private static func set(routineDictionary: [String : Any], routineId: Int?) {
        guard let id = routineId else {
            logError()
            return
        }
        UserDefaults.standard.set(routineDictionary, forKey: String(id))
    }
}
