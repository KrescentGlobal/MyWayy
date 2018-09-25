//
//  AlertStyleViewController.swift
//  MyWayy
//
//  Created by Kyrie Shepherd on 10/31/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class AlertStyleViewController: RoutineCreationOverlayViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var alertStyleLabel: UILabel!
    @IBOutlet weak var alertStyleDataPicker: UIPickerView!
    let alertStyleOptions: [AlertStyle] = [.none, .tones, .bells, .voice, .voicePlusTones]
    var selected: Int {
        return UserDefaults.standard.integer(forKey: "selected")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertStyleDataPicker.delegate = self
        alertStyleDataPicker.dataSource = self
        alertStyleDataPicker.selectRow(selected, inComponent: 0, animated: false)
        alertStyleDataPicker.setValue(UIColor.lightishBlueFullAlpha, forKeyPath: "textColor")
    
    }
    
    @IBAction func backButtonPress(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirm() {
       
        routineModel?.alertStyle = alertStyleOptions[alertStyleDataPicker.selectedRow(inComponent: 0)]
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
            return alertStyleOptions.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let myTitle = NSAttributedString(string:"    \(alertStyleOptions[row].description)", attributes:[NSAttributedStringKey.foregroundColor: UIColor.lightishBlueFullAlpha, NSAttributedStringKey.font: UIFont.medium(20)])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserDefaults.standard.set(row, forKey: "selected")
       
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
            return "\(alertStyleOptions[row])"
        
    }
}
