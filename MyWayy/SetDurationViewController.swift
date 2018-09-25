//
//  SetDurationViewController.swift
//  MyWayy
//
//  Created by Kyrie Shepherd on 11/1/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class SetDurationViewController: ActivityCreationOverlayViewController {
    private var durationTableVc: SetDurationtionTableTableViewController?
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    @IBAction func backButtonPress(_ sender: UIButton) {
        activityModel?.durationTime = nil
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setTimeButton(_ sender: UIButton) {
        durationTableVc?.setDurationFromPicker()

        if activityModel?.durationTime == nil {
            activityModel?.durationTime = 1    //defaulting duration time to 1 minute
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SetDurationtionTableTableViewController {
            vc.activityModel = activityModel
            durationTableVc = vc
        }
    }
}
