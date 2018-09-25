//
//  OverlayViewController.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/6/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class OverlayViewController: UIViewController {

    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        set {
            super.transitioningDelegate = newValue
            modalPresentationStyle = .custom
        }
        get {
            return super.transitioningDelegate
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addRoundedMyWayyShadow(radius: 10)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logDebug(NSStringFromCGRect(view.frame))
    }

    func dismiss(sender: Any?) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
