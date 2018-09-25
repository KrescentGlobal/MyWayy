//
//  CreateRoutineViewController.swift
//  MyWayy
//
//  Created by SpinDance on 10/24/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit
import BetterSegmentedControl
class DayButton: UIButton {
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.backgroundColor = UIColor.lightishBlueFullAlpha.cgColor
            } else {
                layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
}
extension CreateRoutineViewController {
    /// WARNING: Change these constants according to your project's design
    private struct Const {
        /// Image height/width for Large NavBar state
        static let ImageSizeForLargeState: CGFloat = 40
        /// Margin from right anchor of safe area to right anchor of Image
        static let ImageRightMargin: CGFloat = 16
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
        static let ImageBottomMarginForLargeState: CGFloat = -10
        /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
        static let ImageBottomMarginForSmallState: CGFloat = 6
        /// Image height/width for Small NavBar state
        static let ImageSizeForSmallState: CGFloat = 0
        /// Height of NavBar for Small state. Usually it's just 44
        static let NavBarHeightSmallState: CGFloat = 44
        /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
        static let NavBarHeightLargeState: CGFloat = 96.5
        /// Image height/width for Landscape state
        static let ScaleForImageSizeForLandscape: CGFloat = 0.65
    }
}
class CreateRoutineViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BusyOverlayOwner {
    static let storyboardId = "CreateRoutineViewController"
    static let MaxDescriptionLength = 140

   
    weak var routineCreationDelegate: RoutineCreationDelegate?
   
    
    
    var isName = false
    var isEndTime = false
    var isDay = false
    var isAlertStyle = false
    var isCountDownReminder = false
    var isImage = false
    
    
    @IBOutlet weak var visibilityView: UIView!
    /// Set this to create a new routine template (and a routine)
    var routineTemplate: RoutineTemplate?

    /// Set this property when editing a routine and its routine template
    /// NOTE: At this time, this screen only edits both the routine and the
    /// associated routine template. This implies that it should only edit
    /// routines that the current user owns!
    var routine: Routine? {
        didSet {
            guard let r = routine else {
                return
            }
            logDebug("Set routine \(String(describing: r.id)) with version \(String(describing: r.version)))")
            isEdit = true
            routineTemplate = r.getTemplate()
            guard routineTemplate != nil else {
                logError("Cannot get routine template!")
                return
            }
        }
    }
    
    let overlay = BusyOverlayView.create()
    @IBOutlet weak var visibilityMainView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var endTimeButton: UIButton!
    @IBOutlet private weak var repeatLabel: UILabel!
    @IBOutlet private weak var sundayInput: UIButton!
    @IBOutlet private weak var mondayInput: UIButton!
    @IBOutlet private weak var tuesdayInput: UIButton!
    @IBOutlet private weak var wednesdayInput: UIButton!
    @IBOutlet private weak var thursdayInput: UIButton!
    @IBOutlet private weak var fridayInput: UIButton!
    @IBOutlet private weak var saturdayInput: UIButton!
    @IBOutlet private weak var alertStyleButton: UIButton!
    @IBOutlet private weak var countdownRemindersButton: UIButton!
    @IBOutlet private weak var publicPrivateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var descriptionCharacterCount: UILabel!
    @IBOutlet private weak var descriptionField: UITextView!
    @IBOutlet private weak var coverPhotoLabel: UILabel!
    @IBOutlet private weak var coverPhotoIcon: UIButton!
    @IBOutlet private weak var coverPhotoShadowView: UIImageView!
    @IBOutlet private weak var nextButton: UIButton!
    var visibility = 0
    let deselectedColor = UIColor.with(Rgb(r: 201, g: 214, b: 255))
    private lazy var dayButtons: [UIButton] = {
        return [self.sundayInput,
                self.mondayInput,
                self.tuesdayInput,
                self.wednesdayInput,
                self.thursdayInput,
                self.fridayInput,
                self.saturdayInput]
    }()
    private let imagePicker = UIImagePickerController()
    private var routineModel = RoutineCreationViewModel()
    private var numberOfRepeatsEnabled: Int {
        return dayButtons.filter { $0.isSelected }.count
    }
    // Mark :- start end time
    @IBOutlet weak var startTimeTitleLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var startTimeDescriptionLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var startTimeIndicatorImage: UIImageView!
    @IBOutlet weak var startTimeDescriptionLabel: UILabel!
    
    // Mark :- Alert Style
    
    @IBOutlet weak var setAlertTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var alertDescriptionLabel: UILabel!
    @IBOutlet weak var alertDescriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var alertImage: UIImageView!
    
    // Mark :- COUNTDOWN Reminder
   
    @IBOutlet weak var countdownTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var countdownDescriptionLabel: UILabel!
    @IBOutlet weak var countdownDescriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var countdownImage: UIImageView!
    
    // Mark :- NAvigation BaR STYLE
    private let pageController = UIPageControl()
    private var shoulResize = true
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    @IBOutlet weak var crossImage: UIImageView!
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    private var isEdit = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        setupUI()
        
        if UIDevice.current.orientation.isPortrait {
            shoulResize = true
        } else if UIDevice.current.orientation.isLandscape {
            shoulResize = false
        }
        self.hideKeyboardWhenTappedAround()
        setupNameWayyLabel()
        setupRepeatButtons()
        setupVisibilitySwitch()
        setupDescriptionLabel()
        setupCoverPhotoLabel()
      NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showImage(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showImage(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        if shoulResize {
            moveAndResizeImageForPortrait()
        }
    }
    
    // MARK: - Scroll View Delegates
    
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        if shoulResize {
            moveAndResizeImageForPortrait()
        }
    }

    private func showImage(_ show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.pageController.alpha = show ? 1.0 : 0.0
        }
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        title = "Set Up Your Wayy"
        
        let navigationTitleFont = UIFont.medium(14)
        let navigationLargeTitleFont = UIFont.medium(24)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont, NSAttributedStringKey.foregroundColor: UIColor.with(Rgb(r: 73, g: 80, b: 87))]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.font: navigationLargeTitleFont, NSAttributedStringKey.foregroundColor: UIColor.with(Rgb(r: 73, g: 80, b: 87))]
        let navBarsize = navigationController!.navigationBar.bounds.size
        let origin = CGPoint(x: navBarsize.width/2-15, y: 20)
        pageController.frame =  CGRect(x: origin.x, y: origin.y, width: 30, height: 30)
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(pageController)
        pageController.numberOfPages = 2
        pageController.currentPage = 0
        pageController.currentPageIndicatorTintColor = UIColor.with(Rgb(r: 75, g: 116, b: 255))
        pageController.pageIndicatorTintColor = UIColor.with(Rgb(r: 144, g: 144, b: 144))
        NSLayoutConstraint.activate([
            pageController.topAnchor.constraint(equalTo: navigationBar.topAnchor,
                                                constant: -Const.ImageBottomMarginForLargeState),
            pageController.rightAnchor.constraint(equalTo: navigationBar.centerXAnchor, constant: -Const.ImageBottomMarginForLargeState),
            pageController.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            pageController.widthAnchor.constraint(equalTo: pageController.heightAnchor)
            ])
    }
    
    private func moveAndResizeImageForPortrait() {
        guard let height = navigationController?.navigationBar.frame.height else {
            return
        }
        
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()
        
        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState
        
        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()
        
        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()
        
        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        pageController.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
    private func resizeImageForLandscape() {
        let yTranslation = Const.ImageSizeForLargeState * Const.ScaleForImageSizeForLandscape
        pageController.transform = CGAffineTransform.identity
            .scaledBy(x: Const.ScaleForImageSizeForLandscape, y: Const.ScaleForImageSizeForLandscape)
            .translatedBy(x: 0, y: yTranslation)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isEdit {
            routineModel.date = routine?.endTimeAsDate()
            routineModel.alertStyle = routine?.getAlertStyle()
            routineModel.setSelectedRemdinders(from: routine?.reminder)
        }
       
       nameField.isEnabled = true
        updateContent()
    }
   
    @objc func keyboardWillHide(notification: Notification) {
          title = "Set Up Your Wayy"
        nameField.isEnabled = true
        view.removeBlurToBackground(view: self.view, blurView: blurView)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        barButtonItem.isEnabled = true
         barButtonItem.setBackgroundImage(UIImage(named: "backArrowBlack"), for: UIControlState.normal, barMetrics: .default)
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    @objc func keyboardWillShow(notification: Notification) {
          title = "NAME WAYY"
        blurView.backgroundColor = UIColor(red: 242.0/255.0, green: 245.0/255.0, blue: 255.0/255.0, alpha: 0.8)
        view.addBlurToBackground(view: self.view, blurView: blurView)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.view.bringSubview(toFront: (self.navigationController?.navigationBar)!)
       
        textField.becomeFirstResponder()
        barButtonItem.isEnabled = false
        barButtonItem.setBackgroundImage(UIImage(named: "deleteFilled"), for: UIControlState.normal, barMetrics: .default)
       
        navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    @IBAction func hideAc(_ sender: Any) {
        self.view.endEditing(true)
        if nameField.text?.trimmingCharacters(in: .whitespaces) != "" && routineModel.numSelectedReminders > 0 && isCountDownReminder == true && isEndTime == true && isAlertStyle == true && isImage == true{
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.lightishBlueFullAlpha
        }
        else{
            nextButton.isEnabled = false
            nextButton.backgroundColor = deselectedColor
        }
    }
    
    @IBAction func backAc(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Dynamic content setup

    fileprivate func updateContent() {
        view.removeBlurToBackground(view: self.view, blurView: blurView)

        if let date = routineModel.date {
            let dateFormatter = DateFormatter.timeFormatter
           
            startTimeTitleLabelHeight.constant = 10
            startTimeDescriptionLabelHeight.constant = 20.0
            startTimeIndicatorImage.image = UIImage(named: "check")
            startTimeDescriptionLabel.text = "End Time \(dateFormatter.string(from: date))"
            isEndTime = true
        }
        
        if let style = routineModel.alertStyle {
            
            setAlertTitleHeight.constant = 10
            alertDescriptionHeight.constant = 20.0
            alertImage.image = UIImage(named: "check")
            alertDescriptionLabel.text = style.description
            isAlertStyle = true
        }
        
        if routineModel.numSelectedReminders > 0 {
            
            countdownTitleHeight.constant = 10
            countdownDescriptionHeight.constant = 20.0
            countdownImage.image = UIImage(named: "check")
            countdownDescriptionLabel.text = "\(routineModel.numSelectedReminders) Selected"
            isCountDownReminder = true
        }

        if isEdit {
            updateContentForEditing()
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.lightishBlueFullAlpha
        } else {
            updateContentForCreation()
            if nameField.text?.trimmingCharacters(in: .whitespaces) != "" && routineModel.numSelectedReminders > 0 && isCountDownReminder == true && isEndTime == true && isAlertStyle == true && isImage == true {
                nextButton.isEnabled = true
                nextButton.backgroundColor = UIColor.lightishBlueFullAlpha
            }
            else{
                nextButton.isEnabled = false
                nextButton.backgroundColor = deselectedColor
            }
        }
    }

    private func updateContentForCreation() {
        updateWayyName(NSLocalizedString("Tap to name", comment: ""), isPlaceholder: true)
    }

    private func updateContentForEditing() {
        guard let theRoutine = routine, let theRoutineTemplate = routineTemplate else {
            logError()
            return
        }
//        navigationLabel.topItem?.title = NSLocalizedString("EDIT YOUR WAYY", comment: "")
        updateWayyName(theRoutineTemplate.name ?? "", isPlaceholder: false)

        sundayInput.isSelected    = theRoutine.sunday ?? false
        mondayInput.isSelected    = theRoutine.monday ?? false
        tuesdayInput.isSelected   = theRoutine.tuesday ?? false
        wednesdayInput.isSelected = theRoutine.wednesday ?? false
        thursdayInput.isSelected  = theRoutine.thursday ?? false
        fridayInput.isSelected    = theRoutine.friday ?? false
        saturdayInput.isSelected  = theRoutine.saturday ?? false

        descriptionField.text     = theRoutineTemplate.description

        MyWayyService.shared.getRoutineTemplateImage(theRoutineTemplate) { (success, image, error) in
            guard success else {
                logError(error?.localizedDescription)
                return
            }
            self.set(image: image)
        }
    }

    private func updateWayyName(_ name: String, isPlaceholder: Bool) {
        let attrString = NSAttributedString(string:name, attributes:[NSAttributedStringKey.foregroundColor: UIColor.with(Rgb(r: 201, g: 214, b: 255)), NSAttributedStringKey.font: UIFont.medium(32)])
        
        let titleAtrString = NSAttributedString(string:name, attributes:[NSAttributedStringKey.foregroundColor: UIColor.lightishBlueFullAlpha, NSAttributedStringKey.font: UIFont.medium(32)])
        
        if isPlaceholder {
            nameField.attributedPlaceholder = attrString
        } else {
            nameField.attributedText = titleAtrString
        }
    }
  
    // MARK: Static content setup
var textField = UITextField()
    func setupNameWayyLabel() {
        nameField.delegate = self
        
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
        nameField.inputAccessoryView = toolBar
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 11{
            nameField.isEnabled = false
            nameField.text = textField.text
        }
        self.view.endEditing(true)
        if nameField.text?.trimmingCharacters(in: .whitespaces) != "" && routineModel.numSelectedReminders > 0 && isCountDownReminder == true && isEndTime == true && isAlertStyle == true && isImage == true{
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.lightishBlueFullAlpha
        }
        else{
            nextButton.isEnabled = false
            nextButton.backgroundColor = deselectedColor
        }
        return false
    }
    
    func setupVisibilitySwitch(){
        
        let control = BetterSegmentedControl(
            frame: visibilityView.frame,
            segments: LabelSegment.segments(withTitles: ["Private", "Public"],
                                            normalFont: UIFont.heavy(12),
                                            normalTextColor: UIColor(red:206.0/255.0 , green: 212.0/255.0, blue: 218.0/255.0, alpha: 1.0),
                                            selectedFont: UIFont.heavy(12),
                                            selectedTextColor: .white),
            index: 1,
            options: [.backgroundColor(UIColor(red: 241.0/255.0, green: 243.0/255.0, blue: 245.0/255.0, alpha: 1.0)),
                      .indicatorViewBackgroundColor(UIColor.lightishBlueFullAlpha)])
        control.cornerRadius = 19
        control.addTarget(self, action: #selector(self.switchValueDidChange(_:)), for: .valueChanged)
        visibilityMainView.addSubview(control)
        
    }
    
    func setupDescriptionLabel() {
        descriptionField.delegate = self
    }
    
    func setupCoverPhotoLabel(){
        coverPhotoLabel.text = NSLocalizedString("COVER PHOTO", comment: "")
        imagePicker.delegate = self
    }
    
    func addBorder(field: AnyObject) {
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.with(Rgb(r: 224, g: 231, b: 238)).cgColor
        field.layer.cornerRadius = 5
    }
    
    
    @IBAction func switchValueDidChange(_ sender: BetterSegmentedControl) {
        print("The selected index is \(sender.index)")
        if sender.index == 0{
            visibility = 0
        }else{
            visibility = 1
        }
    }
    
 
    func setupRepeatButtons() {
        repeatLabel.text = NSLocalizedString("REPEAT", comment: "")
        for dayButton in dayButtons {
            addBorder(field: dayButton)
            dayButton.layer.cornerRadius = dayButton.frame.height/2.0
        }
    }
    
    // MARK: Textfield Delegate
    
    
    // MARK: TextView Delegte
    func textViewDidBeginEditing(_ textView: UITextView) {
        let defaultText = NSLocalizedString("createRoutineViewController.label.descriptionNotes", comment: "Add notes to your activity here.")
        if textView == descriptionField && descriptionField.text == defaultText {
            descriptionField.text = ""
            descriptionField.textColor = UIColor.with(Rgb(r: 68, g: 82, b: 102))
        }
        view.removeBlurToBackground(view: self.view, blurView: blurView)
        moveViewWhenKeyboardShown(up: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if descriptionField.text.lengthOfBytes(using: String.Encoding.utf8) <= CreateRoutineViewController.MaxDescriptionLength {
            descriptionCharacterCount.text = "\(CreateRoutineViewController.MaxDescriptionLength - descriptionField.text.lengthOfBytes(using: String.Encoding.utf8))"
        }
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descriptionField && descriptionField.text == "" {
            descriptionField.text = NSLocalizedString("createRoutineViewController.label.descriptionNotes", comment: "Add notes to your activity here.")
            descriptionField.textColor = UIColor.with(Rgb(r: 156, g: 171, b: 186))
        }
        moveViewWhenKeyboardShown(up: false)
    }

    // MARK: Actions
    
    @IBAction func next(button: UIButton) {
        let errorMessage = getRequiredFieldsMessage()
        guard errorMessage == nil else {
            logError(errorMessage!)
            showOkErrorAlert(message: errorMessage)
            return
        }
        guard let template = routineTemplate else {
            logError()
            showOkErrorAlert(message: "errorMessage")
            return
        }

        template.profile = MyWayyService.shared.profile?.id
        template.name = nameField.text
        if descriptionField.text != NSLocalizedString("createRoutineViewController.label.descriptionNotes", comment: "") {
            template.description = descriptionField.text
        }
        template.endTime = RoutineTemplate.EndTimeFormat.string(from: routineModel.date!)
        template.sunday = sundayInput.isSelected
        template.monday = mondayInput.isSelected
        template.tuesday = tuesdayInput.isSelected
        template.wednesday = wednesdayInput.isSelected
        template.thursday = thursdayInput.isSelected
        template.friday = fridayInput.isSelected
        template.saturday = saturdayInput.isSelected
        template.alertStyle = routineModel.alertStyle?.rawValue ?? AlertStyle.none.rawValue
        template.reminder = CountdownReminderViewModel.reminderString(from: routineModel.countdownReminders)
       
        if visibility == 0{
             template.isPublic = false
        }else{
             template.isPublic = true
        }
        print("routineTemplate: \(template.updates())")
        
        showOverlay()

        guard isEdit else {
            // Screen is used for creating a routine and its routine template
            MyWayyService.shared.createRoutineTemplate(template, { (success, error) in
                self.handleRoutineTemplateRequestCompletion(template, self.routine, success, error)
            })
            return
        }

        // We're editing a routine and its routine template. Update the template
        // here; the routine will be updated in AddActivitiesViewController
        MyWayyService.shared.updateRoutineTemplate(template: template, { (success, error) in
            self.handleRoutineTemplateRequestCompletion(template, self.routine, success, error)
        })
    }
   
    
    private func handleRoutineTemplateRequestCompletion(_ template: RoutineTemplate?,
                                                        _ routine: Routine?,
                                                        _ success: Bool,
                                                        _ error: NSError?) {
        self.hideOverlay()

        guard success else {
            logError(error?.localizedDescription ?? "" + "\n" + String(describing: error?.userInfo))
            self.showErrorAlert(message: error?.getAwsErrorMessage(),
                                action: UIAlertAction.okAction() { (action) in
                self.routineCreationDelegate?.doneCreatingRoutine()
            })
            return
        }

        guard let vc = UIViewController.addActivities as? AddActivitiesViewController else {
            logError()
            return
        }
        vc.routineCreationDelegate = self
        vc.routineTemplate = template
        vc.routine = routine
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? RoutineCreationOverlayViewController else {
            guard let vc = segue.destination as? AddActivitiesViewController else {
                logError()
                return
            }
            if isEdit {
                vc.routine = routine
            } else {
                vc.routineTemplate = routineTemplate
            }
            return
        }
        view.addBlurToBackground(view: self.view, blurView: blurView)
        vc.routineModel = routineModel
        vc.routineModelDelegate = self
    }
    
    @IBAction func repeatEnableDisable(button: UIButton) {
        button.isSelected = !button.isSelected
    }
  
    @IBAction func uploadCoverPhotoIcon() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let template = routineTemplate else {
            logError()
            return
        }

        MyWayyService.shared.setRoutineTemplateImage(template, image: image, { (success, error) in
            print("success: \(success)")
            if error != nil {
                print("error: \(error!)")
                return
            }
            var buffer = ""
            template.toString(&buffer)
            print("routineTemplate: \(buffer)")
        })

        set(image: image)
        self.dismiss(animated: true, completion: nil)
        isImage = true
        if nameField.text?.trimmingCharacters(in: .whitespaces) != "" && routineModel.numSelectedReminders > 0 && isCountDownReminder == true && isEndTime == true && isAlertStyle == true {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.lightishBlueFullAlpha
        }
        else{
            nextButton.isEnabled = false
            nextButton.backgroundColor = deselectedColor
        }
        
    }

    // MARK: Other

    private func set(image: UIImage?) {
        guard let i = image else { return }

        //TODO: add shadow
        coverPhotoIcon.setImage(i, for: .normal)
        coverPhotoIcon.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8) //Photo slightly larger than icon asset
        coverPhotoIcon.imageView?.layer.cornerRadius = (coverPhotoIcon.imageView?.frame.height)!/2
        coverPhotoShadowView.layer.backgroundColor = UIColor.white.cgColor
        coverPhotoShadowView.layer.shadowColor = UIColor.black.cgColor
        coverPhotoShadowView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        coverPhotoShadowView.layer.shadowRadius = 2
        coverPhotoShadowView.layer.shadowOpacity = 0.7
        coverPhotoShadowView.layer.cornerRadius = coverPhotoShadowView.frame.height/2
        crossImage.isHidden = false
    }
    
    private func getRequiredFieldsMessage() -> String? {
        if nameField.text == "" {
            return NSLocalizedString("Wayy Name required", comment: "")
        } else if routineModel.date == nil {
            return NSLocalizedString("End Time required", comment: "")
        } else if numberOfRepeatsEnabled == 0 {
            return NSLocalizedString("At least one repeat required", comment: "")
        } else if routineModel.alertStyle == nil {
            return NSLocalizedString("Alert Style required", comment: "")
        } else if routineModel.numSelectedReminders == 0 {
            return NSLocalizedString("Countdown Reminders required", comment: "")
        } else if descriptionField.text.isEmpty {
            return NSLocalizedString("Description required", comment: "")
        } else if coverPhotoIcon.imageView?.image == UIImage(named: "coverPhotoIcon") {
            return NSLocalizedString("Cover Photo required", comment: "")
        }
        return nil
    }
}

/// RoutineCreationDelegate for AddActivitiesViewController
extension CreateRoutineViewController: RoutineCreationDelegate {
    func didUpdate(routineModel: RoutineCreationViewModel?) {
        updateContent()
    }

    func doneCreatingRoutine() {
        routineCreationDelegate?.doneCreatingRoutine()
    }
}
