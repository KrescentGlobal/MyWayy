//
//  PublicRoutineSettingsPageViewController.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/12/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class PublicRoutineOutlineView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
}

class PublicRoutineSettingsPageViewController: UIViewController, PublicRoutineViewModelOwner {
    static let storyboardId = String(describing: PublicRoutineSettingsPageViewController.self)

    var routineViewModel: PublicRoutineViewModel?

    @IBOutlet private var heavyStaticLabels: [UILabel]!
    @IBOutlet private weak var endTimeLabel: UILabel!
    @IBOutlet private weak var alertTypeLabel: UILabel!
    @IBOutlet private weak var numberRemindersLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertTypeLabel.text = routineViewModel?.alertStyle.description

        let numReminders = AlertSchedule(scheduleString: routineViewModel?.reminder).sortedDeadlines.count
        numberRemindersLabel.text = NSLocalizedString("\(numReminders) Selected", comment: "")

        if let date = routineViewModel?.endDate {
            endTimeLabel.text = DateFormatter.timeFormatter.string(from: date)
        }
    }

 
}
