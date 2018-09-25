//
//  EditActivityViewController.swift
//  MyWayy
//
//  Created by SpinDance on 12/14/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class EditActivityViewController: UIViewController {
    static let storyboardId = String(describing: EditActivityViewController.self)
    
    var activityTemplate: ActivityTemplate?
    
    @IBOutlet private weak var activityNameLabel: UILabel!
    @IBOutlet private weak var durationOfActivityLabel: UILabel!
    @IBOutlet private weak var durationTimePicker: UIDatePicker!
    @IBOutlet private weak var setTimeButton: UIButton!
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabelsAndInformation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLabelsAndInformation() {
        guard let activity = activityTemplate else {
            return
        }
        activityNameLabel.text = activity.name
        
        durationOfActivityLabel.text = NSLocalizedString("Duration of Activity", comment: "")
        
        durationTimePicker.setValue(UIColor.white, forKeyPath: "textColor")
        //Subtracted 1 from activity.duration because durationTimePickerDefaults to 1 min
        let setPickerDisplayTime = durationTimePicker.date.addingTimeInterval(Double((activity.duration!-1)*Constants.secondsInMinute))
        durationTimePicker.setDate(setPickerDisplayTime, animated: true)
        
        setTimeButton.setTitle(NSLocalizedString("Set Time", comment: ""), for: .normal)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setActivityDurationTime(_ sender: UIButton) {
        guard let activityTemplate = activityTemplate else {
            return
        }
        activityTemplate.duration = Int(durationTimePicker.countDownDuration)/Constants.secondsInMinute
        print("Update duration to: \(activityTemplate.duration!)")
        MyWayyService.shared.updateActivityTemplate(template: activityTemplate, { (success, error) in
            self.dismiss(animated: true, completion: nil)
        })
    }
}
