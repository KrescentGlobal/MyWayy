//
//  CustomMapBarViewController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 30/12/2016.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

import UIKit
import LNPopupController
class CustomRoutineViewController: LNPopupCustomBarViewController {
	
	override var wantsDefaultPanGestureRecognizer: Bool {
		get {
			return false;
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		preferredContentSize = CGSize(width: -1, height: 65)
	}
	
}
