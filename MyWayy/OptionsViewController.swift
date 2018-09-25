//
//  OptionsViewController.swift
//  MyWayy
//
//  Created by SpinDance on 12/14/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit
import WebKit
import MessageUI
import SafariServices

class OptionsViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    static let storyboardId = String(describing: OptionsViewController.self)
    
    @IBOutlet private weak var optionsTitleLabel: UILabel!
    @IBOutlet private weak var inviteView: UIView!
    @IBOutlet private weak var inviteLabel: UILabel!
    @IBOutlet private weak var myContactsLabel: UILabel!
    @IBOutlet private weak var inviteViaSmsButton: UIButton!
    @IBOutlet private weak var accountView: UIView!
    @IBOutlet private weak var accountLabel: UILabel!
    @IBOutlet private weak var editProfileButton: UIButton!
    @IBOutlet private weak var aboutView: UIView!
    @IBOutlet private weak var aboutLabel: UILabel!
    @IBOutlet private weak var termsButton: UIButton!
    @IBOutlet private weak var connectedButton: UIButton!
    @IBOutlet private weak var logoutButton: UIButton!
    
    private let cornerRadius = CGFloat(5)
    private let borderColor = UIColor.paleGrey.cgColor
    private let borderWidth = CGFloat(1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOptionsLabel()
        setupInviteView()
        setupAccountView()
        setupAboutView()
        setupLogoutButton()
    }
    
    func setupOptionsLabel() {
        optionsTitleLabel.text = NSLocalizedString("OPTIONS", comment: "")
    }
    
    func setupInviteView() {
        inviteView.addRoundedMyWayyShadow(radius: 4)
        inviteLabel.text = NSLocalizedString("Invite", comment: "")
        myContactsLabel.text = NSLocalizedString("MY CONTACTS", comment: "")
        inviteViaSmsButton.setTitle(NSLocalizedString("Invite via SMS", comment: ""), for: .normal)
        inviteViaSmsButton.layer.cornerRadius = cornerRadius
        inviteViaSmsButton.layer.borderColor = borderColor
        inviteViaSmsButton.layer.borderWidth = borderWidth
    }
    
    func setupAccountView() {
        accountView.addRoundedMyWayyShadow(radius: 4)
        accountLabel.text = NSLocalizedString("Account", comment: "")
        editProfileButton.setTitle(NSLocalizedString("Edit Profile", comment: ""), for: .normal)
        editProfileButton.layer.cornerRadius = cornerRadius
        editProfileButton.layer.borderColor = borderColor
        editProfileButton.layer.borderWidth = borderWidth
    }
    
    func setupAboutView() {
        aboutView.addRoundedMyWayyShadow(radius: 4)
        aboutLabel.text = NSLocalizedString("About", comment: "")
        termsButton.setTitle(NSLocalizedString("Terms of Use", comment: ""), for: .normal)
        termsButton.layer.cornerRadius = cornerRadius
        termsButton.layer.borderColor = borderColor
        termsButton.layer.borderWidth = borderWidth
        connectedButton.setTitle(NSLocalizedString("Connected North LLC.", comment: ""), for: .normal)
        connectedButton.layer.cornerRadius = cornerRadius
        connectedButton.layer.borderColor = borderColor
        connectedButton.layer.borderWidth = borderWidth
    }
    
    func setupLogoutButton() {
        let username = MyWayyService.shared.profile?.username
        logoutButton.setTitle(NSLocalizedString("Log Out of @\(username!)", comment: ""), for: .normal)
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: share application
    
    @IBAction func shareApplication(sender: UIButton!) {
        guard MFMessageComposeViewController.canSendText() else {
            self.showOkErrorAlert(message: NSLocalizedString("Your device does not support SMS", comment: ""))
            return
        }
        
        let message = NSLocalizedString("profileViewController.shareSms.text", comment: "Check out MyWayy, it is da bomb.")
        let messageComposer = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = self
        messageComposer.body = message
        
        present(messageComposer, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch(result) {
        case .sent: break
        case .failed:
            self.showOkErrorAlert(message: NSLocalizedString("Error sending SMS", comment: ""))
            break
        case .cancelled:
            break
        }
        dismiss(animated: true, completion: nil)
    }
    
      @IBAction func editProfileButton(_ sender: UIButton) {
        guard let vc = UIViewController.editProfile as? EditProfileViewController else {
            return
        }
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.logout()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OptionsWebViewController {
            if segue.identifier == "OptionsWebViewTerms" {
                vc.urlToPresent = PresentedURL.terms.get()
            } else {
                vc.urlToPresent = PresentedURL.connected.get()
            }
        }
    }
    
}

