//
//  ProfileViewController.swift
//  MyWayy
//
//  Created by SpinDance on 10/17/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit
import AANotifier
class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    static let ShowWayys = 0
    static let ShowStats = 1
    static let ShowActivities = 2

    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var myProfileLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var numberOfMinutes: UILabel!
    @IBOutlet private weak var numberOfMinutesLabel: UILabel!
    @IBOutlet private weak var editProfileButton: UIButton!
    @IBOutlet private weak var profilePictureShadowView: UIView!
    @IBOutlet private weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var filterViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var allWaysButton: UIButton!
    @IBOutlet weak var actionSelector: TabySegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!

    private var routineTemplates = [RoutineTemplate]()
    private var activityTemplates = [ActivityTemplate]()

    @IBOutlet weak var statsStreakLengthLabel: UILabel!
    @IBOutlet weak var activityGraph         : UICircularProgressRingView!
    @IBOutlet weak var wayysGraph            : UICircularProgressRingView!
    @IBOutlet weak var streakGraph           : UICircularProgressRingView!
    
    var selectedIndex = [Int]()
    lazy var createPopupNotifier: AANotifier = {
        
        let notifierView = UIView.fromNib(nibName: "createWayypopup")!
        let options: [AANotifierOptions] = [
            .position(.bottom),
            .preferedHeight(250),
            .margins(H: nil, V: nil),
            .hideOnTap(false),
            .transitionA(.fromBottom),
            .transitionB(.toBottom)
        ]
        
        let wayyButton = notifierView.viewWithTag(10) as! UIButton
        wayyButton.addTarget(self, action: #selector(createWayy), for: .touchUpInside)
        let activityButton = notifierView.viewWithTag(20) as! UIButton
        activityButton.addTarget(self, action: #selector(createActivity), for: .touchUpInside)
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
        let notifier = AANotifier(notifierView, withOptions: options)
        return notifier
    }()
    lazy var popupViewNotifier: AANotifier = {
        
        let notifierView = PopupView()
        
        let options: [AANotifierOptions] = [
            .position(.bottom),
            .preferedHeight(100),
            .margins(H: nil, V: 50),
            .transitionA(.fromBottom),
            .transitionB(.toBottom)
        ]
        
        let cancelButton = notifierView.viewWithTag(100) as! UIButton
        cancelButton.addTarget(self, action: #selector(hidePopupView), for: .touchUpInside)
        let deleteButton = notifierView.viewWithTag(101) as! UIButton
        deleteButton.addTarget(self, action: #selector(hidePopupView), for: .touchUpInside)
        
        
        let notifier = AANotifier(notifierView, withOptions: options)
        return notifier
    }()
    
    @objc func hidePopupView() {
        
        popupViewNotifier.hide()
        var activityId = ""
        var profileId = String()
        var index_ = 0
        for activity in selectedIndex{
            if activityId != ""{
                
                 print(selectedIndex[index_])
                print(activityId)
                 activityId = "\(activityId),\(activityTemplates[activity].id!)"
                 activityTemplates.remove(at:selectedIndex[index_])
            }else{
                
                print(selectedIndex[index_])
                 activityId = "\(activityTemplates[activity].id!)"
                 print(activityId)
                activityTemplates.remove(at:selectedIndex[index_])
            }
           index_ = index_ + 1
            profileId = "\(activityTemplates[0].profile!)"
        }
        
        MyWayyService.shared.deleteActivityTemplate(activityId: activityId, profileId: profileId) { (success, error) in
            if success{
                print(success)
               
                self.showOkErrorAlert(message: "\(success)")
                let notifier = self.infoViewNotifier
                notifier.animateNotifer(true, deadline: 2, didTapped: {
                    notifier.hide()
                })
                
            }
        }
        selectedIndex = []
        collectionView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupMyProfileLabel()
        setupNumberOfMinutesLabel()
        setupEditProfileButton()
        setupCollectionView()
        setupGesture()
        setupStatsData()
        actionSelector.initUI()
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(profileUpdated(notification:)), name: Notification.profileReloadedNotification, object: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNameField()
        setupProfilePictureImageView()
        refresh()
        NotificationCenter.default.addObserver(self, selector: #selector(menuButtonAction(notification:)), name: NSNotification.Name(rawValue: "notifyTab"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.profileReloadedNotification, object: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notifyTab"), object: nil)
    }
    @objc func createWayy() {
        for subview in self.view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
       createPopupNotifier.hide()
        presentCreateRoutineScreen(routine: nil, routineTemplate: RoutineTemplate([String: Any]()), delegate: self)
    }
    @objc func createActivity() {
       createPopupNotifier.hide()
        for subview in self.view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "CustomActivityViewController") as? CustomActivityViewController
        self.present(vc!, animated: true, completion: nil)
    }
    @objc private func menuButtonAction(notification: Notification) {
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        
        createPopupNotifier.show()
    }
    // MARK: - Setups
    
    func setupGesture(){
        
        let swipeup = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeup.direction = UISwipeGestureRecognizerDirection.up
        
        let swipedown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipedown.direction = UISwipeGestureRecognizerDirection.down
        
        self.view.addGestureRecognizer(swipeup)
        self.view.addGestureRecognizer(swipedown)
    }
    func setupStatsData(){
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .normal("Longest streak ")
            .bold("7 days")
        
        statsStreakLengthLabel.attributedText = formattedString
    }
   
    // MARK: - Actions
    
    @objc private func menuButtonAction(sender: UIButton) {
      
    }
    
    @objc func profileUpdated(notification: Notification) {
        refresh()
    }

    private func refresh() {
        refreshCollectionViewModels()
        loadCollectionView()
    }

    private func refreshCollectionViewModels() {
        guard let profile = MyWayyService.shared.profile else {
            logError()
            routineTemplates = [RoutineTemplate]()
            activityTemplates = [ActivityTemplate]()
            return
        }
        
        print(profile.routineTemplates)
   //     routineTemplates = profile.routineTemplates
        routineTemplates = profile.routineTemplates.filter {
            RoutineHelper.isFullyInitializedRoutineTemplate($0)
        }
        print(routineTemplates.count)
        activityTemplates = profile.activityTemplates
    }

    func setupMyProfileLabel() {
        backgroundView.addRoundedMyWayyShadow(radius: 8)
        let text = NSLocalizedString("profileViewController.myProfileLabel.text", comment: "MY PROFILE")
        myProfileLabel.text = text
    }
    
    func setupNumberOfMinutesLabel() {
        if let routineMinutes = MyWayyService.shared.profile?.totalRoutineMinutes {
            numberOfMinutes.text = String(routineMinutes)
        }
        numberOfMinutesLabel.text = NSLocalizedString("wayys", comment: "")
    }

    func setupEditProfileButton() {
        let title = NSLocalizedString("profileViewController.editProfileButton.title", comment: "EDIT PROFILE")
        editProfileButton.setTitle(title, for: .normal)
    }

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        statsView.isHidden = true
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        collectionView.addGestureRecognizer(lpgr)
    }
    
    func setupNameField() {
        if let username = MyWayyService.shared.profile?.username {
            usernameLabel.text = username.prependUsernameSymbol()
        }
        if let name = MyWayyService.shared.profile?.name {
            nameLabel.text = name
        }
        if let description = MyWayyService.shared.profile?.description{
            descriptionLabel.text = description
        }
    }

    func setupProfilePictureImageView() {
        MyWayyService.shared.getProfileImage(MyWayyService.shared.profile!, { (success, image, error) in
            if success {
                self.profilePictureImageView.image = image
            }
        })
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.height/2
        profilePictureImageView.layer.borderWidth = 2
        profilePictureImageView.layer.borderColor = UIColor.white.cgColor
        profilePictureShadowView.layer.masksToBounds = false
        profilePictureShadowView.layer.shadowColor = UIColor.lightishBlueFullAlpha.cgColor
        profilePictureShadowView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        profilePictureShadowView.layer.shadowRadius = 4.0
        profilePictureShadowView.layer.shadowOpacity = 0.4
        profilePictureShadowView.layer.cornerRadius = self.profilePictureShadowView.frame.height/2
    }
    
    @IBAction func optionsButton() {
        guard let vc = UIViewController.options as? OptionsViewController else {
            return
        }
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onSelectAction(_ sender: Any) {
        setupCollectionup()
        loadCollectionView()
    }
    
    func setupCollectionup(){
        if actionSelector.selectedSegmentIndex == 0{
            filterViewHeight.constant = 40
            statsView.isHidden = true
            allWaysButton.isSelected = true
        }
        else if actionSelector.selectedSegmentIndex == 1{
            statsView.isHidden = false
            filterViewHeight.constant = 0
        }
        else{
            statsView.isHidden = true
            filterViewHeight.constant = 0
        }
        self.view.frame.origin.y = 0 - self.actionSelector.frame.origin.y - backgroundView.frame.origin.y + 20
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        self.view.frame.size.height = 2 * screenHeight - self.actionSelector.frame.origin.y
    }
    
    func setupCollectionDown(){
      
        self.view.frame.origin.y = 0
        let screenSize: CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        self.view.frame.size.height =  screenHeight
        
    }
    // MARK: Swiping Action
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                setupCollectionup()
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                setupCollectionDown()
                
            default:
                break
            }
        }
    }
    
    // MARK: collection view

    func loadCollectionView() {
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch actionSelector.selectedSegmentIndex {
        case ProfileViewController.ShowWayys:
            return routineTemplates.count
        case ProfileViewController.ShowActivities:
            
            return activityTemplates.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch actionSelector.selectedSegmentIndex {
        case ProfileViewController.ShowWayys:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchRoutineCollectionViewCell.reuseId, for: indexPath) as! SearchRoutineCollectionViewCell
            cell.setup(routineTemplates[indexPath.item])
            cell.clipsToBounds = false
            return cell
        case ProfileViewController.ShowActivities:
            let activityTemplate = activityTemplates[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activitiesCollectionViewCell", for: indexPath) as! ActivityViewCell
            cell.addRoundedMyWayyShadow(radius: 3.8)
            cell.activityNameLabel.text = activityTemplate.name?.uppercased()
            cell.activityIconImage.image = UIImage(named: activityTemplate.icon!)
            cell.activityIconImage.layer.masksToBounds = true
            
            if selectedIndex.contains(indexPath.row){
                 cell.activitySelectedCheckmark.image = UIImage(named : "selectedDelActivity")
                cell.borderWidth = 1.5
            }else if selectedIndex.count > 0{
               cell.activitySelectedCheckmark.image = UIImage(named : "unSelectedActivity")
                cell.borderWidth = 0
            }
            else{
                cell.activitySelectedCheckmark.image = UIImage(named : "")
                cell.borderWidth = 0
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch actionSelector.selectedSegmentIndex {
        case ProfileViewController.ShowWayys:
            return Constants.routineTileSize(from: view.frame)
        case ProfileViewController.ShowActivities:
            return Constants.activityTileSize(from: view.frame)
        default:
            return CGSize(width: 50, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch actionSelector.selectedSegmentIndex {
        case ProfileViewController.ShowWayys:
            presentPublicRoutineScreen(withRoutineTemplate: routineTemplates[indexPath.item])
        case ProfileViewController.ShowActivities:

            if selectedIndex.count > 0{
                if selectedIndex.contains(indexPath.row){
                    selectedIndex.remove(at: selectedIndex.index(of: indexPath.row)!)
                    let indexPathDict:[String: Int] = ["count_": selectedIndex.count]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLabel"), object: nil, userInfo: indexPathDict)
                    if selectedIndex.count == 0 {
                        popupViewNotifier.hide()
                    }
                    else{
                         popupViewNotifier.show()
                    }
                    
                }else{
                    selectedIndex.append(indexPath.row)
                    popupViewNotifier.show()
                    // change label
                     let indexPathDict:[String: Int] = ["count_": selectedIndex.count]
                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLabel"), object: nil, userInfo: indexPathDict)
                     popupViewNotifier.show()
                }
                collectionView.reloadData()
            }

        default:
            logError()
        }
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.collectionView)
        
        if let indexPath = self.collectionView.indexPathForItem(at: p) {
            switch actionSelector.selectedSegmentIndex {
            
            case ProfileViewController.ShowActivities:
               
                if selectedIndex.contains(indexPath.row){
                   
                }else{
                    let indexPathDict:[String: Int] = ["count_": selectedIndex.count]
                    selectedIndex.append(indexPath.row)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLabel"), object: nil, userInfo: indexPathDict)
                    popupViewNotifier.show()
                }
                collectionView.reloadData()
                
            default:
                logError()
            }
        } else {
            print("couldn't find index path")
        }
    }
}
extension ProfileViewController: RoutineCreationDelegate {
    func didUpdate(routineModel: RoutineCreationViewModel?) {
        // Do nothing
    }
    
    func doneCreatingRoutine() {
        dismiss(animated: true, completion: nil)
    }
}
