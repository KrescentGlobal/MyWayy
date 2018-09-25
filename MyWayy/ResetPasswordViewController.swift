//
//  ResetPasswordViewController.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/12/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit

private struct Entry {
    let code: String
    let newPassword: String
    let confirmedPassword: String
    let username: String
}

class ResetPasswordViewController: BaseResetPasswordViewController, UITextFieldDelegate {
    static let storyboardId = String(describing: ResetPasswordViewController.self)

    var username: String?

    @IBOutlet private weak var confirmationCodeLabel: UILabel!
    @IBOutlet private weak var newPasswordLabel: UILabel!
    @IBOutlet private weak var confirmPasswordLabel: UILabel!
    @IBOutlet private weak var confirmationCodeTextField: UITextField!
    @IBOutlet private weak var newPasswordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!

    override var labels: [UILabel] {
        return [confirmationCodeLabel, newPasswordLabel, confirmPasswordLabel]
    }
    override var textFields: [UITextField] {
        return [confirmationCodeTextField, newPasswordTextField, confirmPasswordTextField]
    }

    @IBAction func submitTapped(_ sender: UIButton) {
        doSubmit()
    }

    // MARK: Private

    private func doSubmit() {
        guard let entry = getEntry() else {
            return
        }

        showOverlay()
        MyWayyService.shared.confirmForgotPassword(username: entry.username,
                                                   confirmationCode: entry.code,
                                                   password: entry.newPassword) { (response, error) in
            self.hideOverlay()

            guard error == nil else {
                self.showResetPasswordAlert(with: error! as NSError)
                return
            }

            self.showAlertMessage(alertTitle: NSLocalizedString("Password Reset Successfully", comment: ""),
                                  alertMessage: "",
                                  alertAction: UIAlertAction.okAction() { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            })
        }
    }

    private func getEntry() -> Entry? {
        let code = confirmationCodeTextField.text ?? ""
        let new = newPasswordTextField.text ?? ""
        let confirmed = confirmPasswordTextField.text ?? ""

        guard !code.isEmpty else {
            showEmptyMessageOkAlert(title: NSLocalizedString("Confirmation Code Required", comment: ""))
            return nil
        }
        guard !new.isEmpty else {
            showEmptyMessageOkAlert(title: NSLocalizedString("New Password Required", comment: ""))
            return nil
        }
        guard !confirmed.isEmpty else {
            showEmptyMessageOkAlert(title: NSLocalizedString("Password Confirmation Required", comment: ""))
            return nil
        }
        guard new == confirmed else {
            showEmptyMessageOkAlert(title: NSLocalizedString("Passwords Don't Match", comment: ""))
            return nil
        }
        guard let theUsername = username, !theUsername.isEmpty else {
            showResetPasswordAlert(with: MyWayyService.UnknownUserError)
            return nil
        }

        return Entry(code: code, newPassword: new, confirmedPassword: confirmed, username: theUsername)
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == confirmationCodeTextField {
            newPasswordTextField.becomeFirstResponder()
            return false
        } else if textField == newPasswordTextField {
            confirmPasswordTextField.becomeFirstResponder()
            return false
        } else if textField == confirmPasswordTextField {
            doSubmit()
            textField.resignFirstResponder()
            return true
        } else {
            logError()
            return true
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == newPasswordTextField || textField == confirmPasswordTextField {
            isMovedUp = true
        }
    }
}
