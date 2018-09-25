//
//  ActivityCardView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/21/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class ActivityCardView: UIView {
    static let titleFont = UIFont.heavy(12)
    static let titleColor = UIColor.with(Rgb.gray, Alpha.high)
    static let shadowRadius: CGFloat = 8

    override func awakeFromNib() {
        super.awakeFromNib()
        addRoundedMyWayyShadow(radius: ActivityCardView.shadowRadius)
        backgroundColor = .white
    }
}
