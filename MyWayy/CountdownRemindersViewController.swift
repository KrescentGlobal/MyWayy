//
//  CountdownRemindersViewController.swift
//  MyWayy
//
//  Created by Kyrie Shepherd on 10/31/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class CountdownRemindersViewController: RoutineCreationOverlayViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet private weak var countdownRemindersLabel: UILabel!
  
    @IBOutlet private weak var countdownRemindersTableview: UITableView!

    private let deselectColor = UIColor.with(Rgb(r: 206, g: 212, b: 218))
    private let selectColor = UIColor.lightishBlueFullAlpha

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCountdownRemindersTableView()
    }
    
    func setupCountdownRemindersTableView() {
        countdownRemindersTableview.delegate = self
        countdownRemindersTableview.dataSource = self
    }

    @IBAction func backButtonPress(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func confirm(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routineModel?.countdownReminders.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countdownRemindersCell", for: indexPath)
        let selected = routineModel?.countdownReminders[indexPath.row].selected ?? false
        cell.textLabel?.set(UIFont.medium(20), selected ? selectColor : deselectColor)
        cell.textLabel?.text = routineModel?.countdownReminders[indexPath.row].description
        cell.isSelected = selected
        cell.accessoryType = selected ? .checkmark :.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        routineModel?.countdownReminders[indexPath.row].selected = !(routineModel?.countdownReminders[indexPath.row].selected ?? true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
