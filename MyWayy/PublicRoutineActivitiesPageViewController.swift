//
//  PublicRoutineActivitiesPageViewController.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/12/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

private struct NibNames {
    static let top = "PublicRoutineActivityTopView"
    static let middle = "PublicRoutineActivityEntryView"
    static let bottom = "PublicRoutineActivityBottomView"
}

class PublicRoutineActivitiesPageViewController: UIViewController, PublicRoutineViewModelOwner {
    static let storyboardId = String(describing: PublicRoutineActivitiesPageViewController.self)

    var routineViewModel: PublicRoutineViewModel? {
        didSet {
            setupActivityViews()
        }
    }

    @IBOutlet private weak var stackView: UIStackView?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupActivityViews()
    }

    private func setupActivityViews() {
        guard let theStackView = stackView else {
            // Don't do anything if outlets are not initialized
            return
        }
        guard let r = routineViewModel, let endDate = r.endDate else {
            logError()
            return
        }

        var startDate = endDate.addingTimeInterval(TimeInterval(-r.duration * Constants.secondsInMinute))

        theStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Add the top view
        let topView = UIView.instance(from: NibNames.top) as! PublicRoutineActivityListView
        topView.startDate = startDate
        theStackView.addArrangedSubview(topView)

        // Add a view for each activity template
        r.activities.forEach {
            guard let view = UIView.instance(from: NibNames.middle) as? PublicRoutineActivityEntryView else {
                logError()
                return
            }

            view.set($0, startDate)
            theStackView.addArrangedSubview(view)

            // Update startDate for the next iteration
            startDate = startDate.addingTimeInterval(TimeInterval($0.duration * Constants.secondsInMinute))
        }

        // Add the bottom view
        let bottomView = UIView.instance(from: NibNames.bottom) as! PublicRoutineActivityListView
        bottomView.startDate = r.endDate
        theStackView.addArrangedSubview(bottomView)

        theStackView.arrangedSubviews.forEach {
            $0.addConstraint($0.heightAnchor.constraint(equalToConstant: PublicRoutineActivityListView.height))
        }

        view.setNeedsLayout()
    }
}
