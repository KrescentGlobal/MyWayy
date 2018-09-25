//
//  ShadedImageView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/20/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation
import UIKit

private let defaultAlpha: CGFloat = 0.2
private let defaultWhite: CGFloat = 0.0

class ShadedImageView: UIImageView {
    var fillColor = UIColor.init(white: defaultWhite, alpha: defaultAlpha).cgColor {
        didSet {
            fillLayer.backgroundColor = fillColor
        }
    }

    lazy var fillLayer: CALayer = {
        let newLayer = CALayer()
        newLayer.frame = self.bounds
        newLayer.backgroundColor = self.fillColor
        return newLayer
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.addSublayer(fillLayer)
    }

    override func layoutSubviews() {
        fillLayer.frame = bounds
    }
}
