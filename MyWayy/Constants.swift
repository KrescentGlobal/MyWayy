//
//  Constants.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/10/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

struct Constants {
    static let secondsInMinute = 60
    static let minutesInHour = 60
    static let secondsInHour = secondsInMinute * minutesInHour
    static let hoursInDay = 24

    struct RoutineKeys {
        static let sunday = "sunday"
        static let monday = "monday"
        static let tuesday = "tuesday"
        static let wednesday = "wednesday"
        static let thursday = "thursday"
        static let friday = "friday"
        static let saturday = "saturday"
        static let profile = "profile"
        static let routineTemplate = "routineTemplate"
        static let endTime = "endTime"
        static let alertStyle = "alertStyle"
        static let reminder = "reminder"
        static let image = "image"
    }

    private static let routineCollectionViewCellWidthRatio = CGFloat(0.43) //width specified in wireframes was 160pt on a screen size of 375pt
    private static let routineCollectionViewCellHeigthRatio = CGFloat(0.3) //heigth specified in wireframes was 200pt on a screen size of 667pt
    private static let activityCollectionViewCellWidthRatio = CGFloat(0.25) //width specified in wireframes was 108pt on a screen size of 375pt
    private static let activityCollectionViewCellHeigthRatio = CGFloat(0.13) //heigth specified in wireframes was 89pt on a screen size of 667pt
    
    static func routineTileSize(from rect: CGRect) -> CGSize {
        return CGSize(width: (rect.width * routineCollectionViewCellWidthRatio), height: (rect.width * routineCollectionViewCellWidthRatio) + 40)
    }
    
    static func activityTileSize(from rect: CGRect) -> CGSize {
        return CGSize(width: (rect.width * activityCollectionViewCellWidthRatio), height: (rect.width * activityCollectionViewCellWidthRatio))
    }
}
