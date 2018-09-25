//
//  ActivityProgressView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/11/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation
import UIKit

class ActivityProgressView: UIProgressView {
    private static let height: CGFloat = 12

    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: ActivityProgressView.height).isActive = true
        setMyWayyStyle()
    }

    private func setMyWayyStyle() {
        progressTintColor = UIColor.lightishBlueHighAlpha
        trackTintColor = UIColor.lightishBlueLowAlpha
        progressViewStyle = .default
        layer.cornerRadius = ActivityProgressView.height / 2.0
        clipsToBounds = true
    }
}
