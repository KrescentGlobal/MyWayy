//
//  EndTimeViewController.swift
//  MyWayy
//
//  Created by Kyrie Shepherd on 10/31/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class EndTimeViewController: RoutineCreationOverlayViewController {
    @IBOutlet weak var setEndTimeLabel: UILabel!
    @IBOutlet weak var setTimeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//         let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        view.addBlurToBackground(view: self.view, blurView: blurView)
    }
    
    @IBAction func backButtonPress(_ sender: UIButton) {
        routineModel?.date = nil
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setTimeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EndTimeTableViewController {
            vc.routineModel = routineModel
        }
    }
}
