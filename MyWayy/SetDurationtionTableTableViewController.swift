//
//  SetDurationtionTableTableViewController.swift
//  MyWayy
//
//  Created by Kyrie Shepherd on 11/1/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class SetDurationtionTableTableViewController: UITableViewController {

    var activityModel: CustomActivityModel?
    
    @IBOutlet weak var durationTimePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.clear
        durationTimePicker.setValue(UIColor.lightishBlueFullAlpha, forKeyPath: "textColor")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setDurationFromPicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func handleDurationTimeSelection(_ sender: UIDatePicker, forEvent event: UIEvent) {
        // Todo: This doesn't always get called when the picker's value changes.
        // It's not clear why this is. setDurationFromPicker() was made public
        // to work around this.
        print("TimePicker: \(durationTimePicker.countDownDuration)")
        setDurationFromPicker()
    }

    func setDurationFromPicker() {
        activityModel?.durationTime = Int(durationTimePicker.countDownDuration/60) //countDownDuration set as seconds - divide to get to minutes
    }
}
