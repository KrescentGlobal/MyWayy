//
//  EditProfileViewController.swift
//  MyWayy
//
//  Created by SpinDance on 10/23/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, BusyOverlayOwner {
    static let storyboardId = String(describing: EditProfileViewController.self)

    @IBOutlet private weak var editProfileLabel: UILabel!
    @IBOutlet private weak var profilePhotoShadowView: UIView!
    @IBOutlet private weak var profilePhotoImageView: UIImageView!
    @IBOutlet private weak var changeProfilePhotoButton: UIButton!
    @IBOutlet private weak var profileInfoView: UIView!
    @IBOutlet private weak var profileInfoLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var accountInfoView: UIView!
    @IBOutlet private weak var accountInfoLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var phonenumberLabel: UILabel!
    @IBOutlet private weak var phonenumberField: UITextField!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var updateButton: UIButton!
    
    private let borderColor = UIColor.paleGrey.cgColor
    private let borderWidth = CGFloat(1)
    private let cornerRadius = CGFloat(5)
    
    let imagePicker = UIImagePickerController()
    
    let overlay = BusyOverlayView.create()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        setupEditProfileHeader()
        setupViewShadows()
        setupProfileInfoFields()
        setupAccountInfoFields()
        setupCancelAndUpdateButtons()
        setupProfilePictureImageView()
        imagePicker.delegate = self
    }
    
    func setupEditProfileHeader() {
        editProfileLabel.text = NSLocalizedString("EDIT PROFILE", comment: "")
    }
    
    func setupViewShadows() {
        profileInfoView.addRoundedMyWayyShadow(radius: 4)
        accountInfoView.addRoundedMyWayyShadow(radius: 4)
    }

    func setupProfileInfoFields() {
        profileInfoLabel.text = NSLocalizedString("Profile Info", comment: "")
        nameLabel.text = NSLocalizedString("NAME", comment: "")
        nameField.addLeftPaddingDefault()
        nameField.layer.borderColor = borderColor
        nameField.layer.borderWidth = borderWidth
        nameField.layer.cornerRadius = cornerRadius
        if MyWayyService.shared.profile?.name != MyWayyService.shared.profile?.username {
            nameField.text = MyWayyService.shared.profile?.name
        }
    }
    
    func setupAccountInfoFields() {
        accountInfoLabel.text = NSLocalizedString("Account Info", comment: "")
        emailLabel.text = NSLocalizedString("EMAIL", comment: "")
        emailField.addLeftPaddingDefault()
        emailField.layer.borderColor = borderColor
        emailField.layer.borderWidth = borderWidth
        emailField.layer.cornerRadius = cornerRadius
        emailField.delegate = self
        if MyWayyService.shared.profile?.email != nil {
            emailField.text = MyWayyService.shared.profile?.email
        }
        phonenumberLabel.text = NSLocalizedString("PHONENUMBER", comment: "")
        phonenumberField.addLeftPaddingDefault()
        phonenumberField.layer.borderColor = borderColor
        phonenumberField.layer.borderWidth = borderWidth
        phonenumberField.layer.cornerRadius = cornerRadius
        phonenumberField.delegate = self
        if MyWayyService.shared.profile?.phoneNumber != nil {
            phonenumberField.text = MyWayyService.shared.profile?.phoneNumber
        }
    }

    func setupProfilePictureImageView() {
        changeProfilePhotoButton.setTitle(NSLocalizedString("Change Profile Photo", comment: ""), for: .normal)
        MyWayyService.shared.getProfileImage(MyWayyService.shared.profile!, { (success, image, error) in
            if success {
                self.profilePhotoImageView.image = image
                self.profilePhotoImageView.layer.masksToBounds = false
                self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.height/2
                self.profilePhotoImageView.clipsToBounds = true
            }
        })
        profilePhotoShadowView.layer.shadowColor = UIColor.lightishBlueFullAlpha.cgColor
        profilePhotoShadowView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        profilePhotoShadowView.layer.shadowRadius = 4.0
        profilePhotoShadowView.layer.shadowOpacity = 0.4
        profilePhotoShadowView.layer.cornerRadius = profilePhotoShadowView.frame.height/2
    }
    
    func setupCancelAndUpdateButtons() {
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        updateButton.setTitle(NSLocalizedString("Update", comment: ""), for: .normal)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phonenumberField {
            moveViewWhenKeyboardShown(up: true)
            phonenumberField.text = "+1"
        }
        if textField == emailField {
            moveViewWhenKeyboardShown(up: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phonenumberField || textField == emailField {
            moveViewWhenKeyboardShown(up: false)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    //MARK: Actions
    @IBAction func loadImageButtonPress(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        MyWayyService.shared.profile?.clearUpdates()
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func updateButton(_ sender: UIButton) {
        guard let entry = getAndValidateEmailAndPhoneNumberEntry(emailField: emailField, phoneNumberField: phonenumberField) else {
            return
        }
        
        guard let sharedProfile = MyWayyService.shared.profile else {
            return
        }
        if let image = profilePhotoImageView.image {
            MyWayyService.shared.setProfileImage(MyWayyService.shared.profile!, image: image, { (success, error) in
                //TODO
            })
        }
        sharedProfile.name = nameField.text
        sharedProfile.email = entry.email
        sharedProfile.phoneNumber = entry.phoneNumber
        if sharedProfile.hasUpdates() {
            showOverlay()
            MyWayyService.shared.updateProfile({ (success, error) in
                self.hideOverlay()
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePhotoImageView.image = image
            profilePhotoImageView.layer.masksToBounds = false
            profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.height/2
            profilePhotoImageView.clipsToBounds = true
            dismiss(animated: true, completion: nil)
        }
    }
}
