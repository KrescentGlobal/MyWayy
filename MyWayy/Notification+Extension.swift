//
//  Notification+Extension.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/2/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let appDidEnterBackground = Notification.Name("AppDidEnterBackground")
    static let appWillEnterForeground = Notification.Name("AppWillEnterForeground")
}
