//
//  ViewControllerExtension.swift
//  MyWayy
//
//  Created by Spindance on 10/10/17.
//  Copyright © 2017 Spindance. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: Background theme for Login and New Account flow
    
    
    func setUpBackgroundLogin(mainView : UIView) {
        //Set up gradient in background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = mainView.bounds
        let color1 = UIColor(red: 129/255, green: 173/255, blue: 255/255, alpha: 1.0).cgColor as CGColor
        let color2 = UIColor(red: 75/255, green: 116/255, blue: 255/255, alpha: 1.0).cgColor as CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.00]
        mainView.layer.insertSublayer(gradientLayer, at: 0)
    }
   
    func setUpHeaderUserCreation() {
       
        self.navigationController?.navigationBar.isHidden = false
       // for titles, buttons, etc.
        let navigationTitleFont = UIFont.medium(14)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont, NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    // MARK: Alert Popups
    func showEmptyMessageOkAlert(title: String) {
        showAlertMessage(alertTitle: title, alertMessage: "", alertAction: UIAlertAction.okAction())
    }

    func showOkErrorAlert(message: String?) {
        showErrorAlert(message: message, action: UIAlertAction.okAction())
    }

    func showErrorAlert(message: String?, action: UIAlertAction) {
        showAlertMessage(alertTitle: NSLocalizedString("Error", comment: ""),
                         alertMessage: message ?? "",
                         alertAction: action)
    }

    func showAlertMessage(alertTitle: String, alertMessage: String, alertAction: UIAlertAction) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: Keyboard
    func moveViewWhenKeyboardShown(up: Bool) {
        let moveDistance = -216 //TODO: updated with smallest height of keyboard - need to update with more dynamic height
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animate Move Screen Up", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
