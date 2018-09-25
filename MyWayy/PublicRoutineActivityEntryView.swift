//
//  PublicRoutineActivityEntryView.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/12/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class PublicRoutineActivityEntryView: PublicRoutineActivityListView {
    private static let imageViewWidth: CGFloat = 22
    private static let backgroundImageViewWidthFactor: CGFloat = 1

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var activityIconImageView: UIImageView!
    @IBOutlet private weak var imageBackgroundView: UIView!
    @IBOutlet private weak var imageBackgroundViewWidthConstraint: NSLayoutConstraint!

    private var activityViewModel: PublicActivityViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        imageViewWidthConstraint.constant = PublicRoutineActivityEntryView.imageViewWidth
        imageBackgroundViewWidthConstraint.constant = PublicRoutineActivityEntryView.backgroundImageViewWidthFactor * PublicRoutineActivityEntryView.imageViewWidth
        setStyle()
    }

    func set(_ activityViewModel: PublicActivityViewModel, _ startDate: Date) {
        self.activityViewModel = activityViewModel
        self.startDate = startDate
        setContent()
    }

    private func setStyle() {
       
        imageBackgroundView.backgroundColor = UIColor.veryLightBlueTwo
        imageBackgroundView.addRoundedMyWayyShadow(radius: imageBackgroundView.bounds.size.width / 2.0)
    }

    private func setContent() {
        titleLabel.text = activityViewModel?.name
        durationLabel.text = NSLocalizedString("\(activityViewModel?.duration ?? 0) MINUTES", comment: "")

        if let iconName = activityViewModel?.iconName {
            activityIconImageView.image = UIImage(named: iconName)
        }
    }
}
