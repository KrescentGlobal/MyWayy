//
//  UIAlertAction+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/22/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation

extension UIAlertAction {
    static func okAction(with handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: handler)
    }
}
