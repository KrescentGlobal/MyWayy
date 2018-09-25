//
//  CreateUserViewController.swift
//  MyWayy
//
//  Created by SpinDance on 9/13/17.
//  Copyright © 2017 SpinDance. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class CreateUserViewController: UIViewController, UITextFieldDelegate, BusyOverlayOwner {
    let overlay = BusyOverlayView.create()

    @IBOutlet weak var accountInfoLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!

    @IBOutlet weak var createUserButton: UIButton!
    
    @IBOutlet weak var termsAndConditionsLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    var onboardData = Onboard()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpBackgroundLogin(mainView: self.mainView)
        setUpHeaderUserCreation()
        setupInfoHeadersAndFootnote()
        setupProfileFields()
        setupCreateUserButton()
        setupTermsAndConditionLabel()
    }
    
    func setupInfoHeadersAndFootnote() {
        accountInfoLabel.text = NSLocalizedString("signUpViewController.label.accountInfo", comment: "ACCOUNT INFO")
        
        termsAndConditionsLabel.text = NSLocalizedString("createUserViewController.label.agreeTotTermsAndConditions", comment: "AGREE TO TERMS AND CONDITIONS")
    }

    func setupProfileFields() {
        usernameLabel.text = NSLocalizedString("signUpViewController.label.username", comment: "USERNAME")
        usernameField.addLeftPaddingDefault()
        usernameField.delegate = self
        passwordLabel.text = NSLocalizedString("signUpViewController.label.password", comment: "PASSWORD")
        passwordField.addLeftPaddingDefault()
        passwordField.delegate = self
        
        phoneNumberLabel.text = NSLocalizedString("createUserViewController.label.phoneNumber", comment: "PHONE NUMBER")
        phoneNumberField.addLeftPaddingDefault()
        phoneNumberField.delegate = self
        emailLabel.text = NSLocalizedString("createUserViewController.label.email", comment: "EMAIL")
        emailField.addLeftPaddingDefault()
        emailField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }

    func setupCreateUserButton() {
        let title = NSLocalizedString("createUserViewController.button.createUser", comment: "CREATE ACCOUNT")
        createUserButton.setTitle(title, for: .normal)
    }
    
    func setupTermsAndConditionLabel(){
        let formattedString = NSMutableAttributedString()
        formattedString
            .normal("By clicking Create Account, you agree to our ")
            .bold("Terms and Conditions. ")
            .normal("You may receive notifications from MyWayy and can opt out at any time.")
        
        termsAndConditionsLabel.attributedText = formattedString
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField || textField == passwordField || textField == emailField {
            self.view.endEditing(true)
        }

        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneNumberField {
            phoneNumberField.text = "+1"
        }
        if textField == phoneNumberField || textField == emailField {
            moveViewWhenKeyboardShown(up: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phoneNumberField && textField.text == "+1" {
            phoneNumberField.text = ""
        }
        if textField == phoneNumberField || textField == emailField {
            moveViewWhenKeyboardShown(up: false)
        }
    }

    // MARK: - Actions
    @IBAction func createUser(sender: UIButton?) {
        logDebug("createUser:")

//         self.codeConfirmationView(username: "username", password: "password")
        
        
        guard let username = username() else {
            logDebug("Error: missing username")
            let alertMessage = NSLocalizedString("createUserViewController.error.usernameBlank", comment: "Username cannot be blank")
            self.showOkErrorAlert(message: alertMessage)
            return
        }

        guard let password = password() else {
            logDebug("Error: missing password")
            let alertMessage = NSLocalizedString("createUserViewController.error.passwordBlank", comment: "Password cannot be blank")
            self.showOkErrorAlert(message: alertMessage)
            return
        }

       guard let entry = getAndValidateEmailAndPhoneNumberEntry(emailField: emailField, phoneNumberField: phoneNumberField) else {
            logTrace()
            // The above called method presents its own alert.
            return
        }

        let attributes = ["email": entry.email ?? "", "phone_number": entry.phoneNumber ?? ""]
        onboardData.email = entry.email ?? ""
        onboardData.phone = entry.phoneNumber ?? ""
        
        showOverlay()
        MyWayyService.shared.signUp(username: username, password: password, attributes: attributes, { (response: AWSCognitoIdentityUserPoolSignUpResponse?, nserror: NSError?) in
            self.hideOverlay()

            if let error = nserror {
                var alertMessage = ""

                switch error.code {
                case AWSCognitoIdentityProviderErrorType.usernameExists.rawValue:
                    logError("error: User already exists")
                    alertMessage = NSLocalizedString("createUserViewController.error.usernameAlreadyExisits", comment: "Username already exists")
                case AWSCognitoIdentityProviderErrorType.invalidPassword.rawValue:
                    logError("error: Insufficient password complexity")
                    alertMessage = NSLocalizedString("createUserViewController.error.passwordComplexity", comment: "Insufficient password complexity")
                case AWSCognitoIdentityProviderErrorType.invalidParameter.rawValue:
                    if username == "" {
                        alertMessage = NSLocalizedString("createUserViewController.error.usernameBlank", comment: "Username cannot be blank")
                    } else if (password.count) < 6 {
                        alertMessage = NSLocalizedString("createUserViewController.error.passwordTooShort", comment: "Password must contain at least 6 characters")
                    } else {
                        logError(String(describing: error.localizedDescription))
                        alertMessage = error.localizedDescription
                    }
                default:
                    logError("error: \(error)")
                    alertMessage = error.localizedDescription
                }

                self.showOkErrorAlert(message: alertMessage)
            } else {
                logError("response: \(String(describing: response))")

                if response?.user == nil {
                    logError("No user???")
                    self.showOkErrorAlert(message: NSLocalizedString("No User", comment: ""))
                } else {
                    self.codeConfirmationView(username: username, password: password)
                }
            }
        })
 
    }
    
    func codeConfirmationView(username: String?, password: String?){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CodeConfirmViewController") as? CodeConfirmViewController {
            vc.username = username
            vc.password = password
            vc.onboardData = onboardData
           
            if phoneNumberField.text?.trimmingCharacters(in: .whitespaces) != ""{
               vc.shouldPhone = true
                vc.verifyString = phoneNumberField.text!
              
            }
            else{
                vc.shouldPhone = false
                vc.verifyString = emailField.text!
            }
            vc.modalPresentationStyle = .popover
            self.present(vc, animated: true, completion: nil)
        } else {
            print("Error: unable to show CodeConfirmViewController")
        }
        
    }
    
    func username() -> String? {
        guard let username = usernameField.text, !username.isEmpty else {
            return nil
        }
        return username
    }
    
    func password() -> String? {
        guard let password = passwordField.text, !password.isEmpty else {
            return nil
        }
        return password
    }   

//    func promptUserForConfirmationCode(username: String?, password: String?) {
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            appDelegate.promptUserForConfirmationCode(username: username, password: password)
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TermsAndConditions" {
            let vc = segue.destination as? OptionsWebViewController
            vc?.urlToPresent = PresentedURL.terms.get()
        }
    }
}
