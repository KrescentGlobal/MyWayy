//
//  LoginViewController.swift
//  MyWayy
//
//  Created by SpinDance on 9/13/17.
//  Copyright © 2017 SpinDance. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class LoginViewController: UIViewController, UITextFieldDelegate, BusyOverlayOwner {

    @IBOutlet weak var signInLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var forgetButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerLabel: UILabel!

    let overlay = BusyOverlayView.create()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        setUpBackgroundLogin(mainView: mainView)
        setupLoginView()
        setupRegisterButton()
        setupUsernameField()
        
    }
    override func viewWillAppear(_ animated: Bool) {
       
        setUpHeaderUserCreation()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ForgetPasswordViewController {
            vc.username = usernameField.text
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
   
    func setupLoginView() {
//        signInLabel.text = NSLocalizedString("loginViewController.label.signIn", comment: "Sign in")
//        signInLabel.font = UIFont(name: "Avenir-Heavy", size: 32)
//        
//        forgetButton.setTitle(NSLocalizedString("loginViewController.button.forgetPassword", comment: "Forget?"), for: .normal)
//        forgetButton.titleLabel!.font = UIFont(name: "Avenir-Heavy", size: 12)
        
        usernameLabel.text = NSLocalizedString("USERNAME", comment: "")
        usernameField.addLeftPaddingDefault()
        usernameField.delegate = self
        passwordLabel.text = NSLocalizedString("PASSWORD", comment: "")
        passwordField.addLeftPaddingDefault()
        passwordField.delegate = self
    }
    
    func setupLoginButton() {
        let title = NSLocalizedString("loginViewController.button.logIn", comment: "Log in")
        loginButton.setTitle(title, for: .normal)
      
    }

    func setupRegisterButton() {
//        registerLabel.text = NSLocalizedString("Don't have an account?", comment: "")
//        registerButton.setTitle(NSLocalizedString("Sign Up", comment: ""), for: .normal)
//        registerButton.titleLabel!.font = UIFont(name: "Avenir-Heavy", size: 12)
    }

    func setupUsernameField() {
        usernameField.insertText(MyWayyService.shared.lastUsername())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField || textField == passwordField {
            self.view.endEditing(true)
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordField {
            moveViewWhenKeyboardShown(up: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passwordField {
            moveViewWhenKeyboardShown(up: false)
        }
    }

    // MARK: Actions

    @IBAction func login(_ sender: UIButton) {
        print("LoginViewController.login:")

        let username = usernameField.text
        let password = passwordField.text
        
        if username?.trimmingCharacters(in: .whitespaces) == ""{
            self.showOkErrorAlert(message: "Username cannot be blank")
            return
        }
        if password?.trimmingCharacters(in: .whitespaces) == ""{
            self.showOkErrorAlert(message: "Password cannot be blank")
            return
        }
        
        showOverlay()

        MyWayyService.shared.login(username: username!, password: password!, { (user: AWSCognitoIdentityUser?, response: AWSCognitoIdentityUserSession?, nserror: NSError?) in
            self.hideOverlay()
            if let error = nserror {
                switch error.code {
                case AWSCognitoIdentityProviderErrorType.userNotFound.rawValue:
                    print("error: User does not exist")
                    self.showOkErrorAlert(message: NSLocalizedString("Invalid username or password", comment: ""))
                case AWSCognitoIdentityProviderErrorType.notAuthorized.rawValue:
                    print("error: Invalid username or password")
                    self.showOkErrorAlert(message: "Invalid username or password")
                case AWSCognitoIdentityProviderErrorType.userNotConfirmed.rawValue:
                    self.promptUserForConfirmationCode(username: username, password: password)
                default:
                    print("error: \(error)")
                }
                
            } else {
                print("response: \(String(describing: response))")
                self.loginUser(user!)
            }
            
            print("error: \("code commit")")
        })
    }
    
    

    func loginUser(_ user: AWSCognitoIdentityUser) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.login(user)
        }
    }

    func promptUserForConfirmationCode(username: String?, password: String?) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.promptUserForConfirmationCode(username: username, password: password)
        }
    }
}
