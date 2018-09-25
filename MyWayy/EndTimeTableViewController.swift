//
//  EndTimeTableViewController.swift
//  MyWayy
//
//  Created by Kyrie Shepherd on 10/31/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class EndTimeTableViewController: UITableViewController {
    
    var routineModel: RoutineCreationViewModel?
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEndTimeLabel()
        self.tableView.backgroundColor = UIColor.clear
        endTimePicker.setValue(UIColor.lightishBlueFullAlpha, forKeyPath: "textColor")
    }
    
    func setupEndTimeLabel() {
        let currentDate = Date()
        routineModel?.date = currentDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func handleEndTimeSelection(_ sender: UIDatePicker, forEvent event: UIEvent) {
        routineModel?.date = endTimePicker.date
    }
}
