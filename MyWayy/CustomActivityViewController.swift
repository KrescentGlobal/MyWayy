//
//  CustomActivityViewController.swift
//  MyWayy
//
//  Created by SpinDance on 10/30/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit
import TagListView

class CustomActivityViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, BusyOverlayOwner {
    
    @IBOutlet weak var createActivityNavigationLabel: UINavigationBar!
    @IBOutlet weak var activityNameField: UITextField!
    @IBOutlet weak var tagsExplainedLabel: UILabel!
    @IBOutlet weak var activityIconLabel: UILabel!
    @IBOutlet weak var activityIconImage: UIImageView!
    @IBOutlet weak var activityIconButton: UIButton!
    @IBOutlet weak var activityIconPlusOrX: UIImageView!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet weak var activityDescriptionCharacterCount: UILabel!
    @IBOutlet weak var activityDescriptionField: UITextView!
    @IBOutlet weak var buildAndAddActivityButton: UIButton!
    let deselectedColor = UIColor.with(Rgb(r: 207, g: 251, b: 240))
        var arrTags = [String]()
    let selectedColor = UIColor.with(Rgb(r: 106, g: 225, b: 196))
    
    // Mark :- start end time
    @IBOutlet weak var durationTitleLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var durationDescriptionLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var durationIndicatorImage: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var setDurationTimeButton: UIButton!
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let overlay = BusyOverlayView.create()
    @IBOutlet weak var tagsView: TagListView!
    var activityModel = CustomActivityModel()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barButtonItem: UIButton!
    var isDuration = false
    var isImage    = false
    
    let appDelegateActivity = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        activityNameField.delegate = self
        hideKeyboardWhenTappedAround()
        setupNavigationLabel()
        setupNameActivityLabel()
        
        setupTagsLabel()
        setupIconLabel()
        setupDescriptionLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateContent()
        titleLabel.isHidden = true
        barButtonItem.isHidden = true
        
    }

    @objc func keyboardWillHide(notification: Notification) {
        activityNameField.isEnabled = true
        titleLabel.isHidden = true
        barButtonItem.isHidden = true
        view.removeBlurToBackground(view: self.view, blurView: blurView)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        blurView.backgroundColor = UIColor(red: 242.0/255.0, green: 245.0/255.0, blue: 255.0/255.0, alpha: 0.8)
        view.addBlurToBackground(view: self.view, blurView: blurView)
        barButtonItem.setImage(UIImage(named: "deleteFilled"), for: UIControlState.normal)
        self.view.bringSubview(toFront: barButtonItem)
        self.view.bringSubview(toFront: titleLabel)
        titleLabel.isHidden = false
        barButtonItem.isHidden = false
        barButtonItem.isUserInteractionEnabled = false
        textField.becomeFirstResponder()
        
    }
    
    
    var textField = UITextField()
    func setupNameActivityLabel() {
        activityNameField.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 1)
        toolBar.backgroundColor = UIColor.white
        textField.frame =  CGRect(x: 10, y: 0, width: toolBar.frame.size.width - 20, height: toolBar.frame.size.height)
        textField.becomeFirstResponder()
        textField.textColor = UIColor.lightishBlueHighAlpha
        textField.font = UIFont.medium(32)
        textField.tag = 11
        let barButton = UIBarButtonItem(customView: textField)
        toolBar.setItems([barButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        toolBar.frame.size.height = 60
        textField.delegate = self
        textField.returnKeyType = .done
        activityNameField.inputAccessoryView = toolBar
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 11{
            activityNameField.isEnabled = false
            activityNameField.text = textField.text
        }
        self.view.endEditing(true)
        if activityNameField.text?.trimmingCharacters(in: .whitespaces) != "" &&  isDuration == true && isImage == true{
            buildAndAddActivityButton.isEnabled = true
            buildAndAddActivityButton.backgroundColor = selectedColor
        }
        else{
            buildAndAddActivityButton.isEnabled = false
            buildAndAddActivityButton.backgroundColor = deselectedColor
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.addBlurToBackground(view: self.view, blurView: blurView)
        guard let vc = segue.destination as? ActivityCreationOverlayViewController else {
            logError()
            return
        }
        vc.activityModel = activityModel
        vc.activityCreationDelegate = self
    }

    fileprivate func updateContent() {
        view.removeBlurToBackground(view: self.view, blurView: blurView)
        if activityModel.durationTime != nil {
            formatDurationTimeLabel()
            durationTitleLabelHeight.constant = 10.0
            durationDescriptionLabelHeight.constant = 20.0
            durationIndicatorImage.image = UIImage(named: "check")
            isDuration = true
        }

        tagsView.removeAllTags()
        if  arrTags.count > 0 {
            for tag in arrTags{
                tagsView.addTag(tag)
            }
        }
            
            let tagView = tagsView.addTag("Add Tag")
            tagView.enableRemoveButton = false
            tagView.tagBackgroundColor = UIColor.clear
            tagView.textColor = UIColor.with(Rgb(r: 156, g: 171, b: 186))
            tagView.onTap = { tagView in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddTagsViewController") as! AddTagsViewController
                vc.arrTags = self.arrTags
                self.present(vc, animated: true, completion: nil)
            }
        
        
        if let iconName = activityModel.iconName {
            activityIconImage.image = UIImage(named: iconName)
            activityIconImage.layer.masksToBounds = true
            activityIconPlusOrX.image = UIImage(named: "redX")
            isImage = true
        }
        
        if activityNameField.text?.trimmingCharacters(in: .whitespaces) != "" &&  isDuration == true && isImage == true{
            buildAndAddActivityButton.isEnabled = true
            buildAndAddActivityButton.backgroundColor = selectedColor
        }
        else{
            buildAndAddActivityButton.isEnabled = false
            buildAndAddActivityButton.backgroundColor = deselectedColor
        }
        
    }
    
    func setupNavigationLabel() { createActivityNavigationLabel.titleTextAttributes = [NSAttributedStringKey.font: UIFont.medium(14)]
        
    }
   
    func setupTagsLabel() {
       tagsView.delegate = self
        tagsView.backgroundColor = UIColor.with(Rgb(r: 244, g: 246, b: 249))
        let tagView = tagsView.addTag("Add Tag")
        tagView.enableRemoveButton = false
        tagView.tagBackgroundColor = UIColor.clear
        tagView.textColor = UIColor.with(Rgb(r: 156, g: 171, b: 186))
        tagView.onTap = { tagView in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddTagsViewController") as! AddTagsViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func setupIconLabel() {
        activityIconButton.layer.masksToBounds = false
        activityIconButton.layer.shadowColor = UIColor.black.cgColor
        activityIconButton.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        activityIconButton.layer.shadowRadius = 3.0
        activityIconButton.layer.shadowOpacity = 0.15
        activityIconButton.layer.cornerRadius = activityIconButton.frame.height/2
    }
    
    func setupDescriptionLabel() {
        
        activityDescriptionField.delegate = self
    }
    
  let commentPlaceholder = "\"Make sure while doing this activity...\"";
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == activityDescriptionField && activityDescriptionField.text == commentPlaceholder {
            activityDescriptionField.textColor = UIColor.with(Rgb(r: 51, g: 56, b: 61))
            activityDescriptionField.text = ""
        }
        view.removeBlurToBackground(view: self.view, blurView: blurView)
        moveViewWhenKeyboardShown(up: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if activityDescriptionField.text.lengthOfBytes(using: String.Encoding.utf8) <= CreateRoutineViewController.MaxDescriptionLength {
            activityDescriptionCharacterCount.text = "\(CreateRoutineViewController.MaxDescriptionLength - activityDescriptionField.text.lengthOfBytes(using: String.Encoding.utf8))"
        }
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == activityDescriptionField && activityDescriptionField.text == "" {
            activityDescriptionField.text = commentPlaceholder
            activityDescriptionField.textColor = UIColor.with(Rgb(r: 156, g: 171, b: 186))
        }
        moveViewWhenKeyboardShown(up: false)
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buildAndAddActivity(_ sender: Any) {
        if let errorMessage = getRequiredFieldsMessage() {
            print("Error: \(errorMessage)")
            showOkErrorAlert(message: errorMessage)
            return
        }
        
        showOverlay()
        var fields = [String: Any]()
        fields["profile"] = MyWayyService.shared.profile!.id!
        fields["name"] = activityNameField.text
        fields["duration"] = activityModel.durationTime
        if let tag = activityModel.tag {
            fields["tags"] = tag
        }
        fields["icon"] = activityModel.iconName
        fields["description"] = self.activityDescriptionField.text
        if activityDescriptionField.text != NSLocalizedString("createRoutineViewController.label.descriptionNotes", comment: "") {
            fields["description"] = activityDescriptionField.text
        }
        
        let activityTemplate = ActivityTemplate(fields)
        
        MyWayyService.shared.createActivityTemplate(activityTemplate, { (success, error) in
            self.hideOverlay()
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showOkErrorAlert(message: "Error: \(error!)")
            }
        })
    }
    
    func formatDurationTimeLabel() {
        let mins = Int(activityModel.durationTime!)%60
        let hours = Int(activityModel.durationTime!/60)
        if  hours == 0 {
            durationLabel.text = "\(mins) mins"
        } else if mins == 0 {
             durationLabel.text = "\(hours) hours"
        } else {
             durationLabel.text = "\(hours) hours \(mins) mins"
        }
    }
    
    func getRequiredFieldsMessage() -> String? {
        if activityNameField.text == "" {
            return NSLocalizedString("Activity Name required", comment: "")
        } else if activityModel.durationTime == nil {
            return NSLocalizedString("Duration Time required", comment: "")
        } else if activityModel.iconName == nil {
            return NSLocalizedString("Icon required", comment: "")
        }
        return nil
    }
    
    func addBorder(field: AnyObject) {
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.with(Rgb(r: 224, g: 231, b: 238)).cgColor
        field.layer.cornerRadius = 5
    }
}
extension CustomActivityViewController: TagListViewDelegate{
    // MARK: TagsDelegate
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
       print("Tags pressed")
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        arrTags.remove(at: arrTags.index(of: title)!)
        tagsView.removeTag(title)
    }
}
extension CustomActivityViewController: ActivityCreationDelegate {
    func didUpdate(activityModel: CustomActivityModel?) {
        updateContent()
    }

    func doneCreatingActivity() {
        // Do nothing
    }
}

