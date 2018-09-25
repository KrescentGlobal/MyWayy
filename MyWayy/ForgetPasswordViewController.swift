//
//  ForgetPasswordViewController.swift
//  MyWayy
//
//  Created by SpinDance on 10/18/17.
//  Copyright © 2017 SpinDance. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: BaseResetPasswordViewController, UITextFieldDelegate {

    /*
     * NOTE: Because we only support retrieving a confirmation code via username,
     * and don't yet support doing so by email address, constraints have been set,
     * and views have been set to hidden, in storyboard, to some of the UI on
     * this screen!
     *
     * When email is enabled, change the noEntryText string used below!
     */
    //let noEntryText = NSLocalizedString("Username or Email Required", comment: "")
    let noEntryText = NSLocalizedString("Username Required", comment: "")

    var username: String?
    override var labels: [UILabel] {
        return [usernameLabel, emailLabel]
    }
    override var textFields: [UITextField] {
        return [usernameField, emailField]
    }
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var usernameField: UITextField!
    
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var emailField: UITextField!

    @IBAction func resetPasswordTapped(sender: UIButton) {
        let _ = doResetPassword()
        isMovedUp = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameField.text = username
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if doResetPassword() {
            textField.resignFirstResponder()
        }
        isMovedUp = false
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailField {
            isMovedUp = true
        }
    }

    // MARK: Private

    /// Returns whether the backend was called with the request or not
    private func doResetPassword() -> Bool {
        guard let username = getEntry() else {
            showEmptyMessageOkAlert(title: NSLocalizedString("Username or Email Required", comment: ""))
            return false
        }

        showOverlay()
        MyWayyService.shared.forgotPassword(username: username) { (response, error) in
            self.hideOverlay()

            guard error == nil else {
                self.showResetPasswordAlert(with: error! as NSError)
                return
            }

            guard let vc = UIViewController.resetPassword as? ResetPasswordViewController else {
                self.showOkErrorAlert(message: nil)
                return
            }

            vc.username = username
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return true
    }    

    /// Returns a non-empty string (username or email, with preference on the username)
    /// if a non-empty user textfield entry exists, else returns nil.
    private func getEntry() -> String? {
        let user = usernameField.text ?? ""
        let email = emailField.text ?? ""

        guard !user.isEmpty || !email.isEmpty else {
            return nil
        }

        return !user.isEmpty ? user : email
    }
}
