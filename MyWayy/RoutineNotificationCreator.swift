//
//  RoutineNotificationCreator.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/15/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation
import UserNotifications

struct RoutineNotificationCreator {
    // MARK: Static properties

    fileprivate static let requestIdDelimiter = "_"
    fileprivate static let routineIdUserInfoKey = "routineId"
    fileprivate static let routineStartMinutesDeltaKey = "minutesDelta"

    // MARK: Instance properties

    let routineName: String
    let routineId: Int
    let minutesDelta: Int
    let message: String

    // MARK: requestId helper methods

    /// Creates an identifier for a notification request for a given routine.
    /// The routine name may change, but the id is not expected to change,
    /// therefore the first part of the string can be used to associate this
    /// request with its routine, using the routine id.
    static func createRequestId(routineId: Int, routineName: String, minutesDelta: Int, dateComponents: DateComponents) -> String {
        return createRequestIdPrefix(routineId: routineId) + requestDateIdentifier(from: dateComponents) + requestIdDelimiter + String(minutesDelta)
    }

    static func createRequestIdPrefix(routineId: Int) -> String {
        return String(routineId) + requestIdDelimiter
    }

    static func requestDateIdentifier(from dateComponents: DateComponents) -> String {
        guard let weekday = dateComponents.weekday, let ordinalDay = OrdinalDay(rawValue: weekday) else {
            logDebug("weekday not specified: \(String(describing: dateComponents))")
            return "unknown"
        }
        return ordinalDay.abbreviatedDayString
    }

    // MARK: Other

    static func routineId(for notification: UNNotification) -> Int? {
        return notification.request.content.userInfo[routineIdUserInfoKey] as? Int
    }

    static func minutesDelta(for notification: UNNotification) -> Int? {
        return notification.request.content.userInfo[routineStartMinutesDeltaKey] as? Int
    }
}

// MARK: UNNotificationRequest creation

extension RoutineNotificationCreator {
    /// UNNotificationRequest creation helper method
    /// minutesDelta: Delta from the routines start time, in minutes
    func createNotificationRequest(with startDateComponents: DateComponents) -> UNNotificationRequest? {
        guard let components = startDateComponents.apply(minutesDelta: minutesDelta) else {
            logError()
            return nil
        }

        let requestId = RoutineNotificationCreator.createRequestId(routineId: routineId, routineName: routineName, minutesDelta: minutesDelta, dateComponents: components)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        return createRequest(with: trigger, id: requestId)
    }

    /// For text/debugging purposes!
    func createTestNotificationRequest() -> UNNotificationRequest {
        let requestId = RoutineNotificationCreator.createRequestId(routineId: routineId, routineName: routineName, minutesDelta: minutesDelta, dateComponents: DateComponents())
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutesDelta * Constants.secondsInMinute / 2), repeats: false)
        return createRequest(with: trigger, id: requestId)
    }

    private func createRequest(with trigger: UNNotificationTrigger, id: String) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = routineName
        content.body = message
        content.sound = UNNotificationSound.default()
        content.userInfo[RoutineNotificationCreator.routineIdUserInfoKey] = routineId
        content.userInfo[RoutineNotificationCreator.routineStartMinutesDeltaKey] = minutesDelta
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
}
