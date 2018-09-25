//
//  UIFont+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/11/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    private struct Name {
        static let heavy = "Montserrat-Bold"
        static let medium = "Montserrat-Medium"
        static let book = "Montserrat-Regular"
    }
    static let activeRoutineSettings = UIFont.medium(16)
    static func heavy(_ size: CGFloat) -> UIFont {
        return UIFont(name: Name.heavy, size: size)!
    }
    static func medium(_ size: CGFloat) -> UIFont {
        return UIFont(name: Name.medium, size: size)!
    }

    static func book(_ size: CGFloat) -> UIFont {
        return UIFont(name: Name.book, size: size)!
    }
    
}
