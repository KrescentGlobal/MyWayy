//
//  UIImage+Resize.swift
//  MyWayy
//
//  Created by SpinDance on 11/7/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

extension UIImage {
    func resizeProfile() -> UIImage? {
        return resized(toWidth: 360)
    }

    func resizeRoutineTemplate() -> UIImage? {
        return resized(toWidth: 700)
    }

    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
