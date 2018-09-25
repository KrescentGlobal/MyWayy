//
//  SearchRoutineCollectionViewCell.swift
//  MyWayy
//
//  Created by SpinDance on 11/27/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class SearchRoutineCollectionViewCell: UICollectionViewCell {
    static let reuseId = "SearchRoutineCollectionViewCell"

    @IBOutlet weak var routineTemplateImageView: UIImageView!
    @IBOutlet weak var routineTemplateCreatorNameLabel: UILabel!
    @IBOutlet weak var routineTemplateNameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationLabelUnits: UILabel!

    func setup(_ routineTemplate: RoutineTemplate) {
        self.routineTemplateImageView.image = nil // necessary to prevent leaving an old image in place

        MyWayyService.shared.getRoutineTemplateImage(routineTemplate, { (success, image, error) in
            if !success {
                logError(String(describing: error?.getAwsErrorMessage()))
            }
            self.routineTemplateImageView.image = image
        })
//        routineTemplateImageView.layer.borderWidth = 2.0
//        routineTemplateImageView.layer.borderColor = UIColor.white.cgColor
        //Following adds the shadow to each cell
//        routineTemplateImageView.layer.masksToBounds = false
//        routineTemplateImageView.layer.shadowRadius = 5.0
//        routineTemplateImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        routineTemplateImageView.layer.shadowOpacity = Float(Alpha.medium)
//        routineTemplateImageView.layer.shadowColor = UIColor.black.cgColor

//        if let profile = MyWayyCache.profile(routineTemplate.profile) {
//            routineTemplateCreatorNameLabel.text = profile.name
//        }

        routineTemplateNameLabel.text = routineTemplate.name?.uppercased()

        let minutes = routineTemplate.routineTemplateActivities.reduce(0, { (a, i) in
            return a + (MyWayyCache.activityTemplate(i.activityTemplate)?.duration)!
        })

        let time = ElapsedTimePresenter(seconds: minutes * Constants.secondsInMinute)
        durationLabel.text = time.stopwatchStringShort
        var units = ""
        if minutes > Constants.minutesInHour {
            units = NSLocalizedString("hour", comment: "")
        } else {
            units = NSLocalizedString("min", comment: "")
        }
        durationLabelUnits.text = units
    }
}
