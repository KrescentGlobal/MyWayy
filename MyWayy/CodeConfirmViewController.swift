//
//  CodeConfirmViewController.swift
//  MyWayy
//
//  Created by Spindance on 9/26/17.
//  Copyright © 2017 SpinDance. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class CodeConfirmViewController: UIViewController, UITextFieldDelegate, BusyOverlayOwner {

   
    @IBOutlet weak var phoneOrEmailImage: UIImageView!
    @IBOutlet weak var userPhoneOrEmailLabel: UILabel!
    @IBOutlet weak var userPhoneOrEmailField: UILabel!
    
    @IBOutlet weak var verificationCodeLabel: UILabel!
    @IBOutlet weak var verificationCodeField: UITextField!
    
    @IBOutlet weak var verifyCodeButton: UIButton!
    @IBOutlet weak var resendCodeButton: UIButton!
    
    var username     :    String?
    var password     :    String?
    var shouldPhone  :    Bool?
    var verifyString :    String = String()
    var onboardData = Onboard()
    
    var isMovedUp = false {
        willSet {
            guard newValue != isMovedUp else { return }
            moveViewWhenKeyboardShown(up: newValue)
        }
    }
    
    let overlay = BusyOverlayView.create()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpHeaderUserCreation()
        hideKeyboardWhenTappedAround()
        setupPromptLabels()
        setupPhoneOrEmailImageAndLabels()
        setupVerifyButton()
        setupResendButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        verificationCodeField.text = ""
        verifyCodeButton.isEnabled = false
        verifyCodeButton.backgroundColor = UIColor.lightPeriwinkle
    }
    func setupPhoneOrEmailImageAndLabels(){
        if shouldPhone == false {
            userPhoneOrEmailLabel.text = "EMAIL"
            phoneOrEmailImage.image = UIImage(named: "mail")
        }
        else{
            
            let start = verifyString.index(verifyString.startIndex, offsetBy: 4)
            let end = verifyString.index(verifyString.endIndex, offsetBy: -4)
            let range = start..<end
            
            let mySubstring = String(verifyString[range])
            verifyString = "SMS \(verifyString.replacingOccurrences(of: mySubstring, with: " *** "))"
            
            userPhoneOrEmailLabel.text = "PHONE"
            phoneOrEmailImage.image = UIImage(named: "phone")
        }
        userPhoneOrEmailField.text = verifyString
    }

    func setupPromptLabels() {
     
        verificationCodeLabel.text = NSLocalizedString("codeConfirmViewController.label.verificationCode", comment: "VERIFICATION CODE")
        verificationCodeField.addLeftPaddingDefault()
        verificationCodeField.delegate = self
    }
    
    func setupVerifyButton(){
        let title = NSLocalizedString("codeConfirmViewController.button.verify", comment: "VERIFY")
        verifyCodeButton.setTitle(title, for: .normal)
    }
    
    func setupResendButton(){
        let title = NSLocalizedString("codeConfirmViewController.button.resend", comment: "RESEND VERIFICATION CODE")
        resendCodeButton.setTitle(title, for: .normal)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isMovedUp = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        isMovedUp = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == verificationCodeField {
            self.view.endEditing(true)
        }
        return false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        
        let newLength = text.utf8CString.count
        if newLength >= 5{
            verifyCodeButton.isEnabled = true
            verifyCodeButton.backgroundColor = UIColor.lightishBlueFullAlpha
        }
        else{
            verifyCodeButton.isEnabled = false
            verifyCodeButton.backgroundColor = UIColor.lightPeriwinkle
        }
        
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: actions

    @IBAction func verifyCode(_ sender: UIButton) {
        
        showOverlay()
        MyWayyService.shared.confirm(username: username!, code: confirmationCode()!, { (response: AWSCognitoIdentityUserConfirmSignUpResponse?, nserror: NSError?) in
            if let error = nserror {
                self.hideOverlay()
                var alertMessage: String? = nil

                switch error.code {
                case AWSCognitoIdentityProviderErrorType.codeMismatch.rawValue:
                    logDebug("Invalid confirmation code")
                    alertMessage = NSLocalizedString("Invalid verification code", comment: "")
                case AWSCognitoIdentityProviderErrorType.invalidParameter.rawValue:
                    if self.verificationCodeField.text == "" {
                        alertMessage = NSLocalizedString("Verification Code cannot be blank", comment: "")
                    } else {
                        logDebug(String(describing: error))
                        alertMessage = error.getAwsErrorMessage()
                    }
                default:
                    logDebug(String(describing: error))
                    alertMessage = error.getAwsErrorMessage()
                }
                self.showOkErrorAlert(message: alertMessage)
            } else {
                print("response: \(String(describing: response))")
//                self.loginUser()
                self.onboardData.userName = self.username!
                self.onboardData.password = self.password!
                let nxtVC = self.storyboard?.instantiateViewController(withIdentifier: "onboardNavigation") as! UINavigationController
                if let chidVC = nxtVC.topViewController as? OnboardViewController {
                    chidVC.onboardData = self.onboardData
                }
                self.present(nxtVC, animated: true, completion: nil)
            }
        })
    }
 
    func confirmationCode() -> String? {
        return verificationCodeField.text
    }

    @IBAction func resendVerificationCode(_ sender: UIButton) {
        MyWayyService.shared.resendConfirmation({ (success, error) in
            // TODO: handle success?
        })
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
