//
//  UIColor+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/11/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation
import UIKit

struct Alpha {
    static let none: CGFloat = 0.0
    static let shadedOverlay: CGFloat = 0.1
    static let shadowLow: CGFloat = 0.15
    static let low: CGFloat = 0.19
    static let medium: CGFloat = 0.38
    static let half: CGFloat = 0.5
    static let high: CGFloat = 0.75
    static let full: CGFloat = 1.0
}

struct Rgb {
    let r: UInt8
    let g: UInt8
    let b: UInt8

    // MARK: Common RGBs

    static let lightishBlue = Rgb(r: 75, g: 116, b: 255)
    
    /// RGB is 155
    static let gray = Rgb(r: 155, g: 155, b: 155)
    /// RGB is 74
    static let mediumGray = Rgb(r: 74, g: 74, b: 74)
    static let lightGreen = Rgb(r: 80, g: 227, b: 194)
    static let routineCellDarkGray = Rgb(r: 68, g: 82, b: 102)
    static let routineCellLightGray = Rgb(r: 107, g: 124, b: 147)
    static let routineCellLightestGray = Rgb(r: 178, g: 189, b: 204)
    static let createRoutineDeselectedCellLightBlue = Rgb(r: 208, g: 218, b: 254)
}

extension UIColor {
    static func with(_ rgb: Rgb, _ alpha: CGFloat = Alpha.full) -> UIColor {
        return UIColor(red: rgb.r.asRatio, green: rgb.g.asRatio, blue: rgb.b.asRatio, alpha: alpha)
    }

    static let lightishBlueFullAlpha = UIColor.with(Rgb.lightishBlue, Alpha.full)
    static let lightishBlueHighAlpha = UIColor.with(Rgb.lightishBlue, Alpha.high)
    static let lightishBlueHalfAlpha = UIColor.with(Rgb.lightishBlue, Alpha.half)
    static let lightishBlueMediumAlpha = UIColor.with(Rgb.lightishBlue, Alpha.medium)
    static let lightishBlueLowAlpha = UIColor.with(Rgb.lightishBlue, Alpha.low)
    static let veryLightBlueTwo = UIColor.with(Rgb(r:  237, g: 241, b: 255))
    static let lightPeriwinkle = UIColor.with(Rgb(r:  201, g: 214, b: 255))
    static let activeRoutineSettingsText = UIColor.with(Rgb(r: 103, g: 124, b: 153))
    static let blueyGrey = UIColor.with(Rgb(r: 156, g: 171, b: 186))
    static let charcoalGrey = UIColor.with(Rgb(r: 51, g: 56, b: 61))
    static let lightTeal = UIColor.with(Rgb(r: 106, g: 225, b: 196))
    static let teal = UIColor.with(Rgb(r: 5, g: 192, b: 193))
     static let gunmetal = UIColor.with(Rgb(r: 73, g: 80, b: 87))
    static let paleBlue = UIColor.with(Rgb(r: 243, g: 246, b: 254))
    static let veryLightBluetwo = UIColor.with(Rgb(r: 242, g: 245, b: 255))
    static let aquaMarine = UIColor.with(Rgb(r: 80, g: 227, b: 194))  
    static let shadedOverlayBackground = UIColor.with(Rgb(r: 6, g: 6, b: 6), Alpha.shadedOverlay)
    static let paleGrey = UIColor.with(Rgb(r: 224, g: 231, b: 238))
}

