//
//  LocalNotificationHandler.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/3/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation
import UserNotifications

struct RoutineNotificationInfo {
    let routineId: Int
    let minutesToStart: Int
}

protocol LocalNotificationResponseDelegate: class {
    func shouldShowNotificationForRoutineId(_ routineId: Int) -> Bool
    func notificationArrivedForRoutine(_ notificationInfo: RoutineNotificationInfo)
}

class LocalNotificationHandler: NSObject {
    static let shared = LocalNotificationHandler()

    weak var delegate: LocalNotificationResponseDelegate?

    fileprivate static let authorizationOptions: UNAuthorizationOptions = [.alert, .sound]

    fileprivate var notificationsAllowed = false

    override private init() { }

    func registerAppForLocalNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: LocalNotificationHandler.authorizationOptions) { (granted, error) in
            if let e = error {
                logError(e.localizedDescription)
            }
            self.notificationsAllowed = granted
        }

        UNUserNotificationCenter.current().delegate = self
    }

    func refreshNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: LocalNotificationHandler.authorizationOptions) { (granted, error) in
            self.notificationsAllowed = granted
        }
    }

    /// Adds local notifications for the specified routine using an identifiable
    /// request identifier (see LocalNotificationInfo.createRequestId()),
    /// so that they can be disabled using that name.
    /// Adds local notifications at:
    ///     startTime - n minutes
    ///     startTime
    ///     endTime - n minutes,
    /// Where n is NotificationHandler.reminderDeltaMinutes
    func addNotifications(for routine: Routine?) {
        guard
            notificationsAllowed,
            let r = routine,
            let config = LocalNotificationConfig(routine: r),
            let dateComponentsArray = RoutineHelper.getNotificationDateComponentsArray(for: r)
        else {
            logError()
            return
        }

        // For every day the Wayy is scheduled, add a local notification for each entry in the config
        dateComponentsArray.forEach { (startComponents) in
            config.entries.forEach { (configEntry) in
                //logDebug("Add entry for \(configEntry.routineId) \(configEntry.routineName)")
                guard let request = configEntry.createNotificationRequest(with: startComponents) else {
                    logError()
                    return
                }

                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                    guard error == nil else {
                        logError(error!.localizedDescription)
                        return
                    }
                })
            }
        }
    }

    /// Removes all local notifications for the app. It appears the exact notification
    /// identifier must be used to unregister notifications. Since a single routine
    /// will have several notifications, we will just remove all unconditionally,
    /// which obviously forces all notification to be recreated soon after.
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Asynchronusly prints out the local notifications registered for a given
    /// routine, for debug purposes.
    static func displayPendingNotifications(for routine: Routine?) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            guard
                let name = routine?.getTemplate()?.name,
                let id = routine?.id,
                let duration = routine?.duration()
            else {
                return
            }
            guard requests.count > 0 else {
                logDebug("No pending notification requests")
                return
            }
            requests.filter {
                return $0.identifier.hasPrefix(RoutineNotificationCreator.createRequestIdPrefix(routineId: id))
            }.forEach {
                print("Routine \(id) '\(name)' (\(duration)min) has notification: \($0.myWayyDescription)")
            }
        }
    }
}

extension LocalNotificationHandler: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        guard RoutineNotificationCreator.routineId(for: notification) != nil else {
            logError()
            return
        }
        completionHandler([.alert, .sound])
    }


    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        if let routineId = RoutineNotificationCreator.routineId(for: response.notification),
           let minutes = RoutineNotificationCreator.minutesDelta(for: response.notification) {
            let info = RoutineNotificationInfo(routineId: routineId, minutesToStart: minutes)
            delegate?.notificationArrivedForRoutine(info)
        } else {
            logError()
        }
        completionHandler()
    }
}

/// Debug/test methods
extension LocalNotificationHandler {
    func addDebugNotifications(for routines: [Routine]) {
        for (index, routine) in routines.enumerated() {
            guard let id = routine.id, let name = routine.getTemplate()?.name else {
                logError()
                continue
            }
            let info = RoutineNotificationCreator(routineName: name,
                                             routineId: id,
                                             minutesDelta: index + 1,
                                             message: NSLocalizedString("Test Notification", comment: ""))

            let request = info.createTestNotificationRequest()

            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                guard error == nil else {
                    logError(error!.localizedDescription)
                    return
                }
            })
        }
    }
}
