//
//  PublicRoutineActivityListView.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/12/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class PublicRoutineActivityListView: UIView {
    static let leadingSpace: CGFloat = 78
    static let height: CGFloat = 55
    static let lineWidth: CGFloat = 8
    static let topAndBottomImageWidth: CGFloat = 18

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lineWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineLeadingSpaceConstraint: NSLayoutConstraint!

    var startDate: Date? {
        didSet {
            if let date = startDate {
                timeLabel?.text = DateFormatter.timeFormatter.string(from: date)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        lineWidthConstraint.constant = PublicRoutineActivityListView.lineWidth
        lineLeadingSpaceConstraint.constant = PublicRoutineActivityListView.leadingSpace
        imageViewWidthConstraint.constant = PublicRoutineActivityListView.topAndBottomImageWidth
    }
}
