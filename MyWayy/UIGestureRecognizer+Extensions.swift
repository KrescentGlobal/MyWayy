//
//  UIGestureRecognizer+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/14/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation
import UIKit

extension UIGestureRecognizer {
    func cancel() {
        let wasEnabled = isEnabled
        isEnabled = false
        isEnabled = wasEnabled
    }
}
