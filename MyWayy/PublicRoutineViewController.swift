//
//  PublicRoutineViewController.swift
//  MyWayy
//
//  Created by SpinDance on 12/11/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

// Todo: This and related classes should really be renamed "RoutineDetails..." or
// similar, e.g. RoutineDetailsViewController, since it is used to display both
// Routines and RoutineTemplates.

import UIKit
import AANotifier

private struct PrScreenConstants {
    static let blue = UIColor.lightishBlueFullAlpha
//    static let mediumGrey = UIColor.with(Rgb.mediumGray)
//    static let darkGrey = UIColor.with(Rgb.routineCellDarkGray)
//    static let lightBlue = UIColor.veryLightBlueTwo
    static let dayCircleSize: CGFloat = 16
}

private enum PrScreenPage: Int {
    case activities = 0
    case settings = 1

    var otherPage: PrScreenPage {
        return self == .activities ? .settings : .activities
    }
}

class PublicRoutineViewController: UIViewController, BusyOverlayOwner,  UIScrollViewDelegate{
    
    static let storyboardId = String(describing: PublicRoutineViewController.self)

    let overlay = BusyOverlayView.create()

    var routine: Routine? {
        didSet {
            guard let r = routine else {
                routineViewModel = nil
                return
            }
            guard routineTemplate == nil else {
                logError("Setting routine, but routineTemplate is not nil!")
                return
            }
            routineViewModel = PublicRoutineViewModel.from(routine: r)
        }
    }
    var routineTemplate: RoutineTemplate? {
        didSet {
            guard let t = routineTemplate else {
                routineViewModel = nil
                return
            }
            guard routine == nil else {
                logError("Setting routineTemplate, but routine is not nil!")
                return
            }
            routineViewModel = PublicRoutineViewModel.from(routineTemplate: t)
        }
    }
    var routineViewModel: PublicRoutineViewModel? {
        didSet {
            pages.forEach {
                guard let vc = $0 as? PublicRoutineViewModelOwner else {
                    logError()
                    return
                }
                vc.routineViewModel = routineViewModel
            }
        }
    }
    var userOwnsRoutine = true

    private let initialPage = PrScreenPage.activities
    private var activitiesPage = UIViewController.publicRoutineActivitiesPage as! PublicRoutineActivitiesPageViewController
    private var settingsPage = UIViewController.publicRoutineSettingsPage as! PublicRoutineSettingsPageViewController
    private var pages: [UIViewController] {
        return [activitiesPage, settingsPage]
    }
    private var isLoadingRoutineImage: Bool = false {
        didSet {
            if isLoadingRoutineImage {
                routineImageSpinner.startAnimating()
                routineImageSpinner.isHidden = false
            } else {
                routineImageSpinner.stopAnimating()
                routineImageSpinner.isHidden = true
            }
        }
    }
    private lazy var routineImageViewGradient: CAGradientLayer? = {
        let gradient = CAGradientLayer()
        gradient.frame = self.routineImageView.bounds
        gradient.colors = [UIColor(white: 1, alpha: Alpha.none).cgColor, UIColor(white: 1, alpha: Alpha.high).cgColor]
        return gradient
    }()
    private lazy var activeBtnGradient : CAGradientLayer? = {
        let gradient = CAGradientLayer()
        gradient.frame = self.routineImageView.bounds
        gradient.colors = [UIColor(white: 1, alpha: Alpha.none).cgColor, UIColor(white: 1, alpha: Alpha.high).cgColor]
        return gradient
    }()
    fileprivate var isSubscribed = false {
        didSet {
            subscribedButton.isSelected = isSubscribed

            if isSubscribed {
                routineImageViewGradient?.removeFromSuperlayer()
            } else {
                routineImageView.layer.addSublayer(routineImageViewGradient!)
            }
        }
    }

    @IBOutlet private weak var middleContainerView: UIView!
    @IBOutlet private weak var middleContainerShadowView: UIView!
    @IBOutlet private weak var nextScheduleContainer: UIView!
    @IBOutlet private weak var subscribedButton: UIButton!
    @IBOutlet private weak var bottomContainerView: UIView!
    @IBOutlet weak var segmentedControl: TabySegmentedControl!
    
    @IBOutlet private weak var dayIconsStackView: UIStackView!
    @IBOutlet private weak var nextScheduleLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var routineNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    @IBOutlet private weak var activitiesNumLabel: UILabel!
    @IBOutlet private weak var activitiesTitleLabel: UILabel!
    @IBOutlet private weak var durationNumLabel: UILabel!
    @IBOutlet private weak var durationTitleLabel: UILabel!
    @IBOutlet private weak var routineImageView: UIImageView!
    @IBOutlet private weak var routineImageSpinner: UIActivityIndicatorView!
    @IBOutlet private weak var tagsLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setStyle()
        segmentedControl.selectedSegmentIndex = initialPage.rawValue
        setPage(initialPage)
        let navigationTitleFont = UIFont.medium(14)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont, NSAttributedStringKey.foregroundColor: UIColor.with(Rgb(r: 73, g: 80, b: 87))]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateContent()
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if routineImageView != nil {
            let yPos: CGFloat = -scrollView.contentOffset.y
            
            if yPos > 0 {
                var imgRect: CGRect? = routineImageView?.frame
                imgRect?.origin.y = scrollView.contentOffset.y
                imgRect?.size.height = self.view.frame.size.width/2 + yPos
                routineImageView?.frame = imgRect!
                
                
            }
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        routineImageViewGradient?.frame = routineImageView.bounds
    }
    
    @IBAction func closeTapped(_ sender: Any) {
     self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openMenu(_ sender: Any) {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.alpha = 0.1
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            view.backgroundColor = .white
        }
        actionSheetView.show()
    }
    
    lazy var actionSheetView: AANotifier = {
        
        let notifierView = UIView.fromNib(nibName: "actionSheetView")!
        let options: [AANotifierOptions] = [
            .position(.bottom),
            .preferedHeight(215),
            .margins(H: nil, V: nil),
            .transitionA(.fromBottom),
            .transitionB(.toBottom)
        ]
        let deleteButton = notifierView.viewWithTag(2) as! UIButton
        deleteButton.addTarget(self, action: #selector(showDeletePopup), for: .touchUpInside)
    
        let closeButton = notifierView.viewWithTag(3) as! UIButton
        closeButton.addTarget(self, action: #selector(hideSheetView), for: .touchUpInside)
        
        let notifier = AANotifier(notifierView, withOptions: options)
        return notifier
    }()
    
    
    lazy var infoViewNotifier: AANotifier = {
        
        let notifierView = UIView.fromNib(nibName: "InfoView")!
        let options: [AANotifierOptions] = [
            .position(.top),
            .preferedHeight(80),
            .margins(H: 20, V: 20),
            .transitionA(.fromTop),
            .transitionB(.toTop)
        ]
        let titleLable = notifierView.viewWithTag(1) as! UILabel
        let descriptionLable = notifierView.viewWithTag(2) as! UILabel
        
        titleLable.text = "WAYY DELETED"
        descriptionLable.text = "Wayy deleted successfully."
        let notifier = AANotifier(notifierView, withOptions: options)
        return notifier
    }()
    
    lazy var deletePopupNotifier: AANotifier = {
        
        let notifierView = UIView.fromNib(nibName: "deletePopup")!
        let options: [AANotifierOptions] = [
            .position(.middle),
            .preferedHeight(360),
            .margins(H: 35, V: nil),
            .hideOnTap(false),
            .transitionA(.fromTop),
            .transitionB(.toBottom)
        ]
        
       
        let titleLabel = notifierView.viewWithTag(10) as! UILabel
        titleLabel.attributedText = addtexttoLabel()
        let imageView = notifierView.viewWithTag(11) as! UIImageView
        imageView.image = routineImageView.image
        
        let routineTemplateNameLabel = notifierView.viewWithTag(12) as! UILabel
         let durationLabel = notifierView.viewWithTag(13) as! UILabel
        let durationLabelUnits = notifierView.viewWithTag(14) as! UILabel
        routineTemplateNameLabel.text = routineNameLabel.text
        durationLabel.text = "11:00"
       
        durationLabelUnits.text = "hrs"

        let acceptButton = notifierView.viewWithTag(15) as! UIButton
        acceptButton.addTarget(self, action: #selector(hidePopupView), for: .touchUpInside)
        let declineButton = notifierView.viewWithTag(16) as! UIButton
        declineButton.addTarget(self, action: #selector(declineDelete), for: .touchUpInside)
          var activeBtnGradient : CAGradientLayer? = {
            let gradient = CAGradientLayer()
            gradient.frame = acceptButton.bounds
            gradient.colors = [UIColor(red: 122/255, green: 153/255, blue: 255/255, alpha: 1.0).cgColor, UIColor(red: 161/255, green: 194/255, blue: 255/255, alpha: 1.0).cgColor]
            return gradient
        }()
        acceptButton.layer.addSublayer(activeBtnGradient!)
        let notifier = AANotifier(notifierView, withOptions: options)
        return notifier
    }()
    
    func addtexttoLabel() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "Are you sure you would like to delete Rise and Grind?", attributes: [
            .font: UIFont(name: "Montserrat-Regular", size: 20.0)!,
            .foregroundColor: UIColor.gunmetal
            ])
        attributedString.addAttributes([
            .font: UIFont(name: "Montserrat-Medium", size: 20.0)!,
            .foregroundColor: UIColor.lightishBlueFullAlpha
            ], range: NSRange(location: 38, length: 14))
        return attributedString
    }
    @objc func hideSheetView() {
       
        for subview in self.view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        actionSheetView.hide()
      
        //only apply the blur if the user hasn't disabled transparency effects
       
    }
    
   @objc func showDeletePopup(){
    for subview in self.view.subviews {
        if subview is UIVisualEffectView {
            subview.removeFromSuperview()
        }
    }
    actionSheetView.hide()
    showDeleteViewBlurBg()
    }
    func showDeleteViewBlurBg(){
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            view.backgroundColor = .white
        }
        deletePopupNotifier.show()
    }
    @objc func hidePopupView() {
        for subview in self.view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
      
        deleteRoutine()
        
    }
    @objc func declineDelete() {
        for subview in self.view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        deletePopupNotifier.hide()
    }
    
    func deleteRoutine(){
        
        MyWayyService.shared.deleteRoutine(withId: (routine?.id)!, profileId: (routine?.profile)!) { (success, error) in
    guard success else {
    self.hideOverlay()
         self.deletePopupNotifier.hide()
    return
    }
    
    // Invalidate and reload the cache
    MyWayyCache.invalidate()
            self.deletePopupNotifier.hide()
            let notifier = self.infoViewNotifier
            notifier.animateNotifer(true, deadline: 2, didTapped: {
                notifier.hide()
            })
     self.navigationController?.popViewController(animated: true)
  
    }
    }
    
    @IBAction func subscribeTapped(_ sender: UIButton) {
        guard userOwnsRoutine else {
            // This is someone else's routine, so this is the subscribe/unsubscribe action
            if isSubscribed {
                // If we already know which routine it is, use that, otherwise look it up.
                // The case occurs when this screen is presented from the search or profile
                // tabs and the user does not own this routine's template.
                unsubscribe(from: routine?.id ?? RoutineHelper.findRoutine(with: routineTemplate)?.id)
            } else {
                subscribe(to: routineTemplate)
            }
            return
        }

        // This is the user's routine, so this is the edit wayy action
        presentCreateRoutineScreen(routine: routine, routineTemplate: nil, delegate: self)
    }

   
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case PrScreenPage.activities.rawValue:
            setPage(.activities)
        case PrScreenPage.settings.rawValue:
            setPage(.settings)
        default:
            logError()
            break
        }
    }

    private func setStyle() {
        bottomContainerView.addRoundedMyWayyShadow(radius: 4)
        nextScheduleContainer.backgroundColor         = PrScreenConstants.blue
        nextScheduleContainer.layer.cornerRadius      = 4
        middleContainerView.layer.cornerRadius        = 8

        middleContainerShadowView.layer.masksToBounds = false
        middleContainerShadowView.layer.cornerRadius  = 8
        middleContainerShadowView.layer.shadowRadius  = middleContainerShadowView.layer.cornerRadius
        middleContainerShadowView.layer.shadowOffset  = CGSize(width: 0, height: 0)
        middleContainerShadowView.layer.shadowOpacity = Float(Alpha.high)
        middleContainerShadowView.layer.shadowColor   = UIColor.with(Rgb(r: 103, g: 124, b: 153)).cgColor
        segmentedControl.initUI()
        styleSubscibeButton()
        styleRoutineImageView()
    }

    private func styleRoutineImageView() {
        routineImageView.layer.cornerRadius = 8
        routineImageView.layer.shouldRasterize = true
        routineImageView.layer.masksToBounds = true
    }

   
    private func styleSubscibeButton() {
        if userOwnsRoutine {
            subscribedButton.setTitle(NSLocalizedString("EDIT WAYY", comment: ""), for: .selected)
            subscribedButton.setTitle(NSLocalizedString("EDIT WAYY", comment: ""), for: .normal)
        } else {
            subscribedButton.setTitle(NSLocalizedString("SUBSCRIBED", comment: ""), for: .selected)
            subscribedButton.setTitle(NSLocalizedString("SUBSCRIBE", comment: ""), for: .normal)
        }

        subscribedButton.layer.masksToBounds = true
        subscribedButton.layer.cornerRadius = 12.5
        subscribedButton.setTitleColor(UIColor.white, for: .selected)
        subscribedButton.setTitleColor(UIColor.white, for: .highlighted)
        subscribedButton.setBackgroundImage(UIImage.with(color: PrScreenConstants.blue), for: .selected)
        subscribedButton.setBackgroundImage(UIImage.with(color: PrScreenConstants.blue), for: .highlighted)
        subscribedButton.setTitleColor(PrScreenConstants.blue, for: .normal)
        subscribedButton.setBackgroundImage(UIImage.with(color: UIColor.lightishBlueLowAlpha), for: .normal)
    }

    fileprivate func updateContent() {
        guard
            let r = routineViewModel,
            let weekFlags = r.weekFlags,
            let profile = r.templateOwnerProfile
        else {
            logError()
            return
        }

        isSubscribed = r.isSubscribed

        dayIconsStackView.arrangedSubviews.forEach { dayIconsStackView.removeArrangedSubview($0) }
        weekFlags.setDays.forEach {
            let view = DayIconCircleView(frame: .zero)
            view.day = $0
            dayIconsStackView.addArrangedSubview(view)
            view.setSizeConstraints(width: PrScreenConstants.dayCircleSize)
        }

        updateNextScheduledDateText()
        routineNameLabel.text = r.name
        descriptionLabel.text = r.description
        tagsLabel.text = RoutineHelper.tagStrings(from: r.tags)

        activitiesNumLabel.text = String(routineViewModel?.activities.count ?? 0)
        durationNumLabel.text = ElapsedTimePresenter(seconds: (r.duration) * Constants.secondsInMinute).stopwatchStringShort

        if let username = profile.username {
            usernameLabel.text = NSLocalizedString("@\(username)", comment: "")
        }

        updateRoutineImage()
    }

    private func updateRoutineImage() {
        // Todo: routine template image should be cached; we do quite a few redundant fetches of this.
        guard let template = (routineTemplate ?? routine?.getTemplate()) else {
            // Todo: Is this really an error?
            logError()
            return
        }

        isLoadingRoutineImage = true
        MyWayyService.shared.getRoutineTemplateImage(template, { (success, image, error) in
            self.isLoadingRoutineImage = false
            guard success else {
                logError(String(describing: error))
                self.showAlertMessage(alertTitle: NSLocalizedString("Error downloading Wayy image", comment: ""),
                                      alertMessage: error?.getAwsErrorMessage() ?? "",
                                      alertAction: UIAlertAction.okAction())
                return
            }
            self.routineImageView.image = image
        })
    }

    private func updateNextScheduledDateText() {
        guard
            let r = routineViewModel,
            let endDate = r.endDate,
            let weekFlags = r.weekFlags,
            let nextDate = RoutineHelper.getNextScheduledDate(from: endDate,
                                                              durationMinutes: r.duration,
                                                              weekFlags: weekFlags)
        else {
            logError()
            return
        }
        nextScheduleLabel.attributedText = RoutineHelper.attributedNextScheduledDate(from: nextDate,
                                                                                     withNewline: false,
                                                                                     descriptionColor: UIColor.white,
                                                                                     dateTimeColor: UIColor.white)
    }

    private func setPage(_ page: PrScreenPage) {
        let addedVc = pages[page.rawValue]
        let removedVc = pages[page.otherPage.rawValue]

        removedVc.willMove(toParentViewController: nil)
        removedVc.view.removeFromSuperview()
        removedVc.removeFromParentViewController()

        addChildViewController(addedVc)
        bottomContainerView.addSubview(addedVc.view)
        addedVc.view.frame = bottomContainerView.bounds
        addedVc.didMove(toParentViewController: self)
        addedVc.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomContainerView.leadingAnchor.constraint(equalTo: addedVc.view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: addedVc.view.trailingAnchor),
            bottomContainerView.topAnchor.constraint(equalTo: addedVc.view.topAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: addedVc.view.bottomAnchor)])

        view.setNeedsLayout()
    }
}

extension PublicRoutineViewController: RoutineCreationDelegate {
    func didUpdate(routineModel: RoutineCreationViewModel?) {
        // Do nothing
    }

    func doneCreatingRoutine() {
        // This is an edit (creation is performed from the home screen).
        // So reload the cache...
        showOverlay()
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        MyWayyCache.invalidate()
        MyWayyService.shared.loadProfile { (success, error) in
            self.hideOverlay()
            guard success else {
                self.showErrorAlert(message: error?.getAwsErrorMessage(),
                                    action: UIAlertAction.okAction() { (action) in
                    self.dismiss(animated: true, completion: nil)
                })
                return
            }

            // Force a refresh of routineViewModel
            if let r = self.routine {
                guard
                    let id = r.id,
                    let fetchedRoutine = MyWayyService.shared.profile?.getRoutineById(id)
                else {
                    logError()
                    return
                }
                self.routine = fetchedRoutine
            } else if let t = self.routineTemplate {
                guard
                    let id = t.id,
                    let fetchedTemplate = MyWayyService.shared.profile?.getRoutineTemplateById(id)
                else {
                    logError()
                    return
                }
                self.routineTemplate = fetchedTemplate
            }
            self.updateContent()
        }
    }
}

/// Subscribe/Unsubscribe functionality
extension PublicRoutineViewController {
    fileprivate func unsubscribe(from routineId: Int?) {
        let errorBlock: (String?) -> Void = { (message) in
            self.showAlertMessage(alertTitle: NSLocalizedString("Error unsubscribing to Wayy", comment: ""),
                                  alertMessage: message ?? "",
                                  alertAction: UIAlertAction.okAction())
        }

        guard let id = routineId else {
            errorBlock(nil)
            return
        }
        
        guard let profileId = routine?.profile else {
            errorBlock(nil)
            return
        }

        // Delete the routine
        showOverlay()
        MyWayyService.shared.deleteRoutine(withId: id, profileId: profileId) { (success, error) in
            guard success else {
                self.hideOverlay()
                errorBlock(error?.getAwsErrorMessage())
                return
            }

            // Invalidate and reload the cache
            MyWayyCache.invalidate()
            
            MyWayyService.shared.loadProfile { (success, error) in
                self.hideOverlay()
                guard success else {
                    errorBlock(error?.localizedDescription)
                    return
                }

                NotificationCenter.default.post(name: Notification.profileReloadedNotification, object: nil)

                // Upon success, dismiss this screen
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    fileprivate func subscribe(to routineTemplate: RoutineTemplate?) {
        guard let template = routineTemplate else {
            logError()
            showOkErrorAlert(message: NSLocalizedString("", comment: ""))
            return
        }

        showOverlay()
        MyWayyService.shared.subsribeCurrentUser(to: template) { (success, error) in
            self.hideOverlay()

            if success {
                self.isSubscribed = true
                self.showAlertMessage(alertTitle: NSLocalizedString("Subscribed", comment: ""),
                                      alertMessage: "",
                                      alertAction: UIAlertAction.okAction() { (action) in
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                logError()
                self.showAlertMessage(alertTitle: NSLocalizedString("Error Subscribing to Wayy", comment: ""),
                                      alertMessage: error?.getAwsErrorMessage() ?? "",
                                      alertAction: UIAlertAction.okAction())
            }
        }
    }
}
