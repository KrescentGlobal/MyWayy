//
//  NumberExtensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/12/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

extension UInt8 {
    var asRatio: CGFloat {
        return CGFloat(self) / CGFloat(UInt8.max)
    }
}
