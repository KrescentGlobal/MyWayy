//
//  RoutineCreationOverlayViewController.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/8/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit

class RoutineCreationOverlayViewController: UIViewController {
    var routineModel: RoutineCreationViewModel?
    weak var routineModelDelegate: RoutineCreationDelegate?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        routineModelDelegate?.didUpdate(routineModel: routineModel)
    }
}
