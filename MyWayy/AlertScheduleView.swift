//
//  AlertScheduleView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/27/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

private let imageSize: CGFloat = 8

private class AlertImageView: UIImageView {
    var alertDeadlineMinutes: UInt = 0 {
        didSet {
            completed = false
        }
    }
    var completed: Bool = false {
        didSet {
            image = UIImage(named: completed ? "alert circle complete" : "alert circle incomplete")
        }
    }
}

class AlertScheduleView: UIView {

    // MARK: Public Properties

    var activityDuration = 0 {
        didSet {
            reinitializeImageViews()
        }
    }

    var alertSchedule = AlertSchedule(scheduleString: nil) {
        didSet {
            alertImageViews.forEach { $0.removeFromSuperview() }
            alertImageViews = alertSchedule.sortedDeadlines.map {
                let iv = AlertImageView(image: nil)
                iv.alertDeadlineMinutes = $0
                iv.contentMode = UIViewContentMode.scaleAspectFit
                addSubview(iv)
                return iv
            }
        }
    }

    // MARK: Private Properties

    private var alertImageViews = [AlertImageView]()

    // MARK: Public Methods

    override func layoutSubviews() {
        super.layoutSubviews()
        alertImageViews.forEach {
            guard let _  = $0.superview else { return }
            reposition($0)
        }
    }

    func alertFired(at minutesRemaining: UInt) {
        alertImageViews.forEach {
            $0.completed = $0.alertDeadlineMinutes >= minutesRemaining
        }
    }

    func add(_ minutes: Int, secondsRemaining: Int) {
        // Update the total time of the activity. This causes the alert image
        // views to be reinitialized
        activityDuration += minutes

        // If secondsRemaining is not an even multiple of 60, then we need to round up
        // the minutes used in the call below to account for truncation that occurs
        // in integer division. Otherwise alerts that shouldn't have fired will be
        // mistakenly marked as completed.
        var minutesRemaining = secondsRemaining / Constants.secondsInMinute
        minutesRemaining += (secondsRemaining % Constants.secondsInMinute > 0) ? 1 : 0

        // Refresh the completed state of the alert image views
        alertFired(at: UInt(minutesRemaining))
    }

    // MARK: Private Methods

    private func reinitializeImageViews() {
        for (index, deadline) in alertSchedule.sortedDeadlines.enumerated() {
            let iv = alertImageViews[index]
            iv.completed = false
            iv.removeFromSuperview()

            // Make sure each schedule entry is within range of the current duration.
            // (An alert schedule applies to all activities in a routine, and a
            // given activity might actually be shorter than some of the schedule
            // entries.)
            let totalTime = CGFloat(activityDuration)
            let alertTime = totalTime - CGFloat(deadline)
            guard alertTime > 0.0 else {
                logDebug("Schedule \(alertSchedule) has entry \(deadline) that is out of range for duration \(activityDuration)")
                continue
            }

            reposition(iv)
            addSubview(iv)
        }
    }

    private func reposition(_ imageView: AlertImageView) {
        // Set the imageView's X origin so that its center lines up proportionally
        // with its corresponding schedule entry.
        let totalTime = CGFloat(activityDuration)
        let alertTime = totalTime - CGFloat(imageView.alertDeadlineMinutes)
        var frame = imageView.frame
        frame.origin.x = (bounds.width * (alertTime / totalTime)) - (imageSize / 2.0)
        frame.origin.y = (bounds.size.height - imageSize) / 2.0
        frame.size.width = imageSize
        frame.size.height = imageSize
        imageView.frame = frame
    }
}
