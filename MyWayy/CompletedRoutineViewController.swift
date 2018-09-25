//
//  CompletedRoutineViewController.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/6/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class CompletedRoutineViewController: OverlayViewController {
    static let storyboardId = String(describing: CompletedRoutineViewController.self)

    var routineResults: RoutineTimeResults?

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var recapLabel: UILabel!
    @IBOutlet private weak var startTimeTitleLabel: UILabel!
    @IBOutlet private weak var endTimeTitleLabel: UILabel!
    @IBOutlet private weak var numActivitiesLabel: UILabel!
    @IBOutlet private weak var onTimeLabel: UILabel!
    @IBOutlet private weak var middleTimeLabel: UILabel!
    @IBOutlet private weak var endTimeLabel: UILabel!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var dividerLineView: UIView!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var nextScheduleTitleLabel: UILabel!
    @IBOutlet private weak var nextScheduleLabel: UILabel!
    @IBOutlet private weak var timeLineContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let r = routineResults else {
            logError()
            return
        }
        updateUi(with: r)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(sender: sender)
    }

    private func setStyle() {
        timeLineContainerView.backgroundColor = UIColor.with(Rgb(r: 250, g: 250, b: 250))
        timeLineContainerView.layer.borderWidth = 1
        timeLineContainerView.layer.borderColor = UIColor.paleBlue.cgColor
        timeLineContainerView.layer.cornerRadius = 4
        dividerLineView.backgroundColor = UIColor.veryLightBlueTwo

        let smallerFont = UIFont.heavy(10)
        let biggerFont = UIFont.heavy(12)
        let buttonFont = UIFont.medium(16)

        titleLabel.set(biggerFont, UIColor.with(Rgb.mediumGray))
        recapLabel.set(biggerFont, UIColor.activeRoutineSettingsText)

        [startTimeTitleLabel, startTimeLabel].forEach {
            $0?.set(smallerFont, UIColor.aquaMarine)
        }
        [endTimeTitleLabel, endTimeLabel].forEach {
            $0?.set(smallerFont, UIColor.lightishBlueFullAlpha)
        }
        middleTimeLabel.set(smallerFont, UIColor.with(Rgb(r: 180, g: 188, b: 200)))
        numActivitiesLabel.set(biggerFont, UIColor.with(Rgb.mediumGray))
        onTimeLabel.set(smallerFont, UIColor.with(Rgb.mediumGray, Alpha.half))
        confirmButton.setTitleColor(UIColor.lightishBlueFullAlpha, for: .normal)
        confirmButton.titleLabel?.font = buttonFont
    }

    private func updateUi(with results: RoutineTimeResults) {
        startTimeLabel.text = DateFormatter.timeFormatter.string(from: results.startTime)
        middleTimeLabel.text = DateFormatter.timeFormatter.string(from: results.middleTime)
        endTimeLabel.text = DateFormatter.timeFormatter.string(from: results.actualEndTime)
        numActivitiesLabel.text = NSLocalizedString("\(results.numActivities) Activities", comment: "")

        let minutesDelta = Int(results.actualDurationSec - results.expectedDurationSec) / Constants.secondsInMinute
        if minutesDelta == 0 {
            onTimeLabel.text = NSLocalizedString("On Time", comment: "")
        } else if minutesDelta > 0 {
            onTimeLabel.text = NSLocalizedString("+ \(minutesDelta) MINUTES ADDED", comment: "")
        } else {
            onTimeLabel.text = NSLocalizedString("+ \(abs(minutesDelta)) MINUTES EARLY", comment: "")
        }

        nextScheduleLabel.attributedText = RoutineHelper.attributedNextScheduledDate(from: results.nextOccuranceDate, withNewline: true)
    }
}
