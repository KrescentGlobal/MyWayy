//
//  UNNotificationRequest+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/15/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation
import UserNotifications

extension UNNotificationRequest {
    var myWayyDescription: String {
        let id = identifier
        let title = content.title
        let subtitle = content.subtitle
        let body = content.body

        var string = "id: '\(id)'; title: '\(title)'; subtitle: '\(subtitle)'; body: '\(body)'"

        if let date = (trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() {
            let day = DateFormatter.shortDateFormatter.string(from: date)
            let time = DateFormatter.timeFormatter.string(from: date)
            string.append("; on: \(day) at \(time)")
        } else {
            string.append("; NO TRIGGER DATE!")
            logError(String(describing: (trigger as? UNCalendarNotificationTrigger)?.dateComponents))
        }

        if let triggerComponents = (trigger as? UNCalendarNotificationTrigger)?.dateComponents {
            let weekday = triggerComponents.weekday?.description ?? ""
            let hour = triggerComponents.hour?.description ?? ""
            let minute = triggerComponents.minute?.description ?? ""
            let second = triggerComponents.second?.description ?? ""
            string.append("; wkday: \(weekday); hms:\(hour):\(minute):\(second)")
        }

        return string
    }
}
