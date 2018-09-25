//
//  BaseResetPasswordViewController.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/12/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit

class BaseResetPasswordViewController: UIViewController, BusyOverlayOwner {
    let labelFont = UIFont.heavy(10)
    let buttonFont = UIFont.medium(16)
    let textFieldFont = UIFont.medium(14)
    let overlay = BusyOverlayView.create()
    var textFields: [UITextField] {
        return [UITextField]()
    }
    var labels: [UILabel] {
        return [UILabel]()
    }
    var isMovedUp = false {
        willSet {
            guard newValue != isMovedUp else { return }
            moveViewWhenKeyboardShown(up: newValue)
        }
    }

    @IBOutlet weak var backButton: UIButton?
    @IBOutlet weak var submitButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        hideKeyboardWhenTappedAround()
        setUpBackgroundLogin(mainView: self.view)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func backTapped(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    func showResetPasswordAlert(with error: NSError) {
        logError(String(describing: error.localizedDescription) + "\n" + String(describing: error.userInfo))
        showOkErrorAlert(message: error.getAwsErrorMessage())
    }

    @objc func keyboardWillHide(notification: Notification) {
        isMovedUp = false
    }

    private func setStyle() {
        labels.forEach { $0.font = labelFont }
        textFields.forEach {
            $0.addLeftPaddingDefault()
            $0.font = textFieldFont
            // The following matches the login screen
            $0.textColor = .white
            $0.backgroundColor = UIColor.with(Rgb(r: 242, g: 240, b: 240), 0.4)
            $0.alpha = 1
        }
        backButton?.titleLabel?.font = labelFont
        submitButton?.titleLabel?.font = buttonFont
    }
}
