//
//  DateFormatter+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/15/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter
    }()

    static var shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()
}
