//
//  VerticalConstraintHideableView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/27/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class VerticalConstraintHideableView: UIView {
    enum ScreenLocation {
        case top, bottom

        var closeGestureDirection: UISwipeGestureRecognizerDirection {
            return self == .top ? .up : .down
        }
    }

    private lazy var backgroundOverlay: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.shadedOverlayBackground
        view.alpha = Alpha.none
        return view
    }()

    var screenLocation = ScreenLocation.top
    var blockParentView = false
    var showAnimationDurationSec = TimeInterval(0.5)
    lazy var hideAnimationDurationSec: TimeInterval = { self.showAnimationDurationSec * 0.67 }()
    var hideConstraint: NSLayoutConstraint?
    var showConstraint: NSLayoutConstraint?
    var overlayHideConstraint: NSLayoutConstraint?
    var overlayTopConstraint: NSLayoutConstraint?
    var overlayBottomConstraint: NSLayoutConstraint?
    weak var parentView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()

        addGestureRecognizer(createCloseGesture())

        if blockParentView {
            backgroundOverlay.addGestureRecognizer(createCloseGesture())
        }
    }

    func add(to parentView: UIView) {
        self.parentView = parentView

        if blockParentView {
            // Initialize the overlay first so it ends up behind self inside parentView.
            initializeBackgroundOverlayView()
        }

        initializeView()
    }

    @objc func swipeToClose(gesture: UIGestureRecognizer) {
        set(hidden: true)
    }

    @IBAction func closeTapped(_ sender: UIButton) {
        set(hidden: true)
    }

    func set(hidden: Bool) {
        // Setting all related constraints to false first before activating or
        // deactivating them seems to prevent runtime warnings
        if blockParentView {
            [overlayBottomConstraint, overlayTopConstraint, overlayHideConstraint].forEach { $0?.isActive = false }
            [overlayBottomConstraint, overlayTopConstraint].forEach { $0?.isActive = !hidden }
            overlayHideConstraint?.isActive = hidden

            // Don't animate the overlay layout change, but do animate it's alpha
            // change (below) to prevent it flashing in the UI
            parentView?.layoutIfNeeded()
        }

        [hideConstraint, showConstraint].forEach { $0?.isActive = false }
        hideConstraint?.isActive = hidden
        showConstraint?.isActive = !hidden
        UIView.animate(withDuration: hidden ? hideAnimationDurationSec : showAnimationDurationSec) {
            self.backgroundOverlay.alpha = hidden ? Alpha.none : Alpha.full
            self.parentView?.layoutIfNeeded()
        }
    }

    private static func addSideConstraints(from view: UIView, to parentView: UIView) {
        view.leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
    }

    private func initializeBackgroundOverlayView() {
        guard let parentView = self.parentView else { return }
        parentView.addSubview(backgroundOverlay)

        // These constraints don't change
        VerticalConstraintHideableView.addSideConstraints(from: backgroundOverlay, to: parentView)

        overlayTopConstraint = backgroundOverlay.topAnchor.constraint(equalTo: parentView.topAnchor)
        overlayBottomConstraint = backgroundOverlay.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)

        switch screenLocation {
        case .top:
            overlayHideConstraint = backgroundOverlay.bottomAnchor.constraint(equalTo: parentView.topAnchor)
        case .bottom:
            overlayHideConstraint = backgroundOverlay.topAnchor.constraint(equalTo: parentView.bottomAnchor)
        }
        overlayHideConstraint?.isActive = true // Default to hidden
    }

    private func initializeView() {
        guard let parentView = self.parentView else { return }
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)

        // These constraints don't change
        VerticalConstraintHideableView.addSideConstraints(from: self, to: parentView)

        switch screenLocation {
        case .top:
            hideConstraint = bottomAnchor.constraint(equalTo: parentView.topAnchor)
            showConstraint = topAnchor.constraint(equalTo: parentView.topAnchor)
        case .bottom:
            hideConstraint = topAnchor.constraint(equalTo: parentView.bottomAnchor)
            showConstraint = bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        }
        hideConstraint?.isActive = true // Default to hidden
    }

    private func createCloseGesture() -> UIGestureRecognizer {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToClose(gesture:)))
        gesture.direction = screenLocation.closeGestureDirection
        return gesture
    }
}
