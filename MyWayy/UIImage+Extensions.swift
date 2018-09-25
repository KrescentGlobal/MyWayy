//
//  UIImage+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/13/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation
import AVKit

extension UIImage {
    static func with(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
