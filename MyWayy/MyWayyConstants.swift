//
//  MyWayyConstants.swift
//  MyWayy
//
//  Created by SpinDance on 10/24/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

class MyWayy {
    static let ErrorDomain = "com.mywayy.error"
    static let activeRoutineExtensionMinutes = 1
}

enum MyWayyErrorStates: Int {
    case Unknown = 0
    case Client = 1
    case Network = 2
    case AWS = 3
    case Validation = 4
}

