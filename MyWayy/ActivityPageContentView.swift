//
//  ActivityPageContentView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/20/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

protocol NotesViewToggleDelegate: class {
    func toggleViews(animated: Bool)
}

class ActivityPageContentView: UIView, NotesViewToggleDelegate {
    static let nibName = String(describing: ActivityPageContentView.self)
    static let reuseId = nibName

    /// This is the scale of the activity view or notes view that is in the
    /// background, scaled down to this scale, and offset vertically somewhat.
    private static let backgroundScale: CGFloat = 0.9
    private static let backgroundVerticalOffset: CGFloat = -35

    var secondsRemaining: Int = 0 {
        didSet {
            activityView.secondsRemaining = secondsRemaining
            guard secondsRemaining > 0 || !notesAreShowing else {
                toggleViews(animated: true)
                return
            }
        }
    }
    weak var delegate: ActiveActivityViewDelegate? { didSet { activityView.delegate = delegate } }
    var activity: Activity? {
        didSet {
            notesView.notes = activity?.getTemplate()?.description ?? NSLocalizedString("No notes.", comment: "")
            activityView.secondsRemaining = activity?.durationInSeconds ?? 0
            activityView.name = activity?.getTemplate()?.name ?? ""
        }
    }

    /// The user can toggle which of notesView or activityView is in front.
    private lazy var notesView: ActivityNotesView = {
        let view = UIView.instance(from: ActivityNotesView.nibName) as! ActivityNotesView
        view.toggleDelegate = self
        return view
    }()

    /// See notesView
    private(set) lazy var activityView: ActiveActivityView = {
        let view = UIView.instance(from: ActiveActivityView.nibName) as! ActiveActivityView
        return view
    }()
    private var notesAreShowing = true // Set to true so the first toggleViews() works...

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    @objc func userSwipedDown(gesture: UIGestureRecognizer) {
        toggleViews(animated: true)
    }

    func toggleViews(animated: Bool) {
        let duration = animated ? 0.25 : 0
        let foregroundView = notesAreShowing ? notesView : activityView
        let backgroundView = notesAreShowing ? activityView : notesView
        self.notesAreShowing = !self.notesAreShowing

        UIView.animate(withDuration: duration, animations: {
            self.restoreTransform(for: backgroundView)
            self.setBackgroundTransform(for: foregroundView)
            self.bringSubview(toFront: backgroundView)
        })
    }

    private func setup() {
        [notesView, activityView].forEach {
            let view = $0 as! UIView
            addSubview(view)
            setConstraints(from: view)
        }

        // Don't clip so the background view shows
        clipsToBounds = false

        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(userSwipedDown(gesture:)))
        downSwipe.direction = .down
        addGestureRecognizer(downSwipe)

        toggleViews(animated: false)
    }

    private func setBackgroundTransform(for view: UIView) {
        let scale = ActivityPageContentView.backgroundScale
        let originalTransform = view.transform
        let scaledTransform = originalTransform.scaledBy(x: scale, y: scale)
        let h = view.bounds.size.height
        let y: CGFloat = ((scale * h - h) / 2.0) + ActivityPageContentView.backgroundVerticalOffset
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 0.0, y: y)
        view.transform = scaledAndTranslatedTransform
    }

    private func restoreTransform(for view: UIView) {
        view.transform = CGAffineTransform.identity
    }

    private func setConstraints(from subview: UIView) {
        let pad: CGFloat = 0
        let margins = layoutMarginsGuide
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: margins.topAnchor, constant: pad).isActive = true
        subview.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -pad).isActive = true
        subview.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: pad).isActive = true
        subview.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -pad).isActive = true
    }
}
