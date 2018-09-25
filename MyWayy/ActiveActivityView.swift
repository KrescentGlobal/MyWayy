//
//  ActiveActivityView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/9/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

protocol ActiveActivityViewDelegate: class {
    func userSingleTapped(_ activityView: ActiveActivityView)
    func userDoubleTapped(_ activityView: ActiveActivityView)
}

private enum ActivityViewState {
    case running
    case paused
    case completed

    var statusImageHidden: Bool {
        return !timerLabelHidden
    }

    var timerLabelHidden: Bool {
        switch self {
        case .running:
            return false
        case .paused, .completed:
            return true
        }
    }

    var statusLabelText: String {
        switch self {
        case .running:
            return NSLocalizedString("REMAINING", comment: "")
        case .paused:
            return NSLocalizedString("PAUSED", comment: "")
        case .completed:
            return NSLocalizedString("COMPLETED", comment: "")
        }
    }

    var statusImage: UIImage? {
        switch self {
        case .running:
            return nil
        case .paused:
            return UIImage(named: "play circle")
        case .completed:
            return UIImage(named: "checked circle")
        }
    }
}

class ActiveActivityView: ActivityCardView {
    static let nibName = String(describing: ActiveActivityView.self)

    static func create(name: String, seconds: Int, delegate: ActiveActivityViewDelegate?, owner: Any?) -> ActiveActivityView {
        let view = Bundle.main.loadNibNamed(ActiveActivityView.nibName, owner: owner, options: nil)?.first as! ActiveActivityView
        view.delegate = delegate
        view.name = name
        view.secondsRemaining = seconds
        return view
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countdownTimerLabel: UILabel!
    @IBOutlet private weak var remainingLabel: UILabel!
    @IBOutlet private weak var statusImageView: UIImageView!
    var name: String? { didSet { nameLabel.text = name } }
    weak var delegate: ActiveActivityViewDelegate?
    var secondsRemaining = 0 {
        didSet {
            countdownTimerLabel.text = ElapsedTimePresenter(seconds: secondsRemaining).stopwatchStringShort
            viewState = (secondsRemaining == 0) ? .completed : .running
        }
    }
    var paused: Bool = false {
        didSet {
            guard viewState != .completed else { return }
            viewState = paused ? .paused : .running
        }
    }
    private var viewState = ActivityViewState.running {
        didSet {
            countdownTimerLabel.isHidden = viewState.timerLabelHidden
            statusImageView.isHidden = viewState.statusImageHidden
            remainingLabel.text = viewState.statusLabelText
            statusImageView.image = viewState.statusImage
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.set(ActivityCardView.titleFont, ActivityCardView.titleColor)
        nameLabel.set(UIFont.medium(20), UIColor.with(Rgb(r: 34, g: 41, b: 51), Alpha.full))
        countdownTimerLabel.set(UIFont.heavy(90), UIColor.lightishBlueFullAlpha)
        countdownTimerLabel.adjustsFontSizeToFitWidth = true
        countdownTimerLabel.minimumScaleFactor = 0.5
        countdownTimerLabel.numberOfLines = 0
        remainingLabel.set(UIFont.heavy(20), UIColor.with(Rgb.routineCellDarkGray))

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(userDidTap(gesture:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(userDidDoubleTap(gesture:)))
        singleTap.numberOfTapsRequired = 1
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(singleTap)
        addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)
    }

    @objc private func userDidTap(gesture: UIGestureRecognizer) {
        delegate?.userSingleTapped(self)
    }

    @objc private func userDidDoubleTap(gesture: UIGestureRecognizer) {
        delegate?.userDoubleTapped(self)
    }
}
