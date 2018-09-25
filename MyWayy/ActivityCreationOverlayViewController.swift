//
//  ActivityCreationOverlayViewController.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/9/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit

class ActivityCreationOverlayViewController: UIViewController {
    var activityModel: CustomActivityModel?
    weak var activityCreationDelegate: ActivityCreationDelegate?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activityCreationDelegate?.didUpdate(activityModel: activityModel)
    }
}
