//
//  HomeScreenViewController.swift
//  MyWayy
//
//  Created by SpinDance on 9/26/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//


import UIKit
import LNPopupController
import AWSCognitoIdentityProvider
import AANotifier

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BusyOverlayOwner {
    static let storyboardId = String(describing: HomeScreenViewController.self)

    let overlay = BusyOverlayView.create()

    fileprivate var cellModels = [RoutineTableViewCellModel]()
    fileprivate var todaysRoutines = [Routine]() {
        didSet {
            // Reset the cell models
            cellModels = [RoutineTableViewCellModel]()

            for routine in todaysRoutines {
                // Create and add a new model
                let model = RoutineTableViewCellModel()
                cellModels.append(model)
                model.ownerName = ""
                model.routineId = routine.id
                model.routineName = routine.getTemplate()?.name
                model.durationSeconds = routine.durationInSeconds
                model.isLoading = true

                // Show the owner name if the current user does not own this routine
                if let currentUserId = MyWayyService.shared.profile?.id,
                    let ownerId = routine.getTemplate()?.profile,
                    let ownerName = routine.getTemplate()?.getProfile()?.username,
                    currentUserId != ownerId {
                    model.ownerName = ownerName
                }
            }

            // Reload the view
            routineTableView?.reloadData()

            // Load the image for each routine, refreshing its row upon completion
            for (index, routine) in todaysRoutines.enumerated() {
                if let template = routine.getTemplate() {
                    MyWayyService.shared.getRoutineTemplateImage(template) { (success, image, error) in
                        self.cellModels[index].routineImage = image
                        self.cellModels[index].isLoading = false
                        self.routineTableView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
            }

            // Reset notifications
            // Todo: Perhaps determine if the routine list has changed to prevent
            // resetting notifications everytime this is called.
            LocalNotificationHandler.shared.removeAllNotifications()

            todaysRoutines.forEach {
                LocalNotificationHandler.shared.addNotifications(for: $0)
            }

           
            // For Debugging
            //LocalNotificationHandler.shared.addDebugNotifications(for: todaysRoutines)

            
            // For Debugging
            logDebug("NEW NOTIFICATIONS (wait for it...):")
            todaysRoutines.forEach {
                LocalNotificationHandler.displayPendingNotifications(for: $0)
            }
        }
    }
private var popupContentVC: ActiveRoutineViewController!
    @IBOutlet fileprivate weak var routineTableView: UITableView?
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navigationTitleFont = UIFont.medium(14)
        let navigationLargeTitleFont = UIFont.medium(24)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont, NSAttributedStringKey.foregroundColor: UIColor.with(Rgb(r: 73, g: 80, b: 87))]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.font: navigationLargeTitleFont, NSAttributedStringKey.foregroundColor: UIColor.with(Rgb(r: 73, g: 80, b: 87))]
        
        let headerNib = UINib.init(nibName: "HomeHeader", bundle: nil)
        routineTableView?.register(headerNib, forHeaderFooterViewReuseIdentifier: "HomeHeader")
    
         routineTableView?.register(UINib.init(nibName: "HomeRoutineItems", bundle: nil), forCellReuseIdentifier: "myTableCell")
        routineTableView?.register(UINib.init(nibName: "ComingRoutineItems", bundle: nil), forCellReuseIdentifier: "myTableCell2")
        updateModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileUpdated(notification:)), name: Notification.profileReloadedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startWayys(notification:)), name: NSNotification.Name(rawValue: "notifyMe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startNewWayys(notification:)), name: NSNotification.Name(rawValue: "notifyMeLongPress"), object: nil)
       
        self.navigationItem.title =  "Good Morning, \(MyWayyService.shared.lastUsername())"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(menuButtonAction(notification:)), name: NSNotification.Name(rawValue: "notifyTab"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.profileReloadedNotification, object: nil)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "notifyTab"), object: nil)
    }
    
    @objc func profileUpdated(notification: Notification) {
        updateModel()
    }
    
    @objc func startWayys(notification : Notification){
        let routine = todaysRoutines[ (notification.userInfo?["index"] as? Int)!]
         presentPublicRoutineScreen(withRoutine: routine)
    }
    
    @objc func startNewWayys(notification : Notification){
        let routine = todaysRoutines[ (notification.userInfo?["index"] as? Int)!]
        presentActiveRoutineScreen(with: routine)
    }
    
    @objc func createWayy() {
        for subview in self.view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        createPopupNotifier.hide()
        createRoutine()
    }
    
    @objc func createActivity() {
        for subview in self.view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        createNewActivity()
        createPopupNotifier.hide()
    }
    
    func startRoutineWithId(_ routineId: Int) {
        // Refresh the model to ensure we're up to date when this internal method is called
        updateModel()

        guard let index = todaysRoutines.index(where: { (thisRoutine) -> Bool in
            guard let id = thisRoutine.id, id == routineId else {
                return false
            }
            return true
        }) else {
            logError("Could not find routine with ID \(routineId)")
            return
        }

        let action = {
            self.presentActiveRoutineScreen(with: self.todaysRoutines[index])
        }

        // If a screen is presented modally, first dismiss it.
        guard presentedViewController == nil else {
            dismiss(animated: true, completion: {
                action()
            })
            return
        }

        action()
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
    
    
    fileprivate func updateModel() {
        guard
            let allRoutines = MyWayyService.shared.profile?.routines,
            let today = NSCalendar.current.dateComponents([.weekday], from: Date()).weekday
        else {
            logError(String(describing: MyWayyService.shared.profile?.routines.count))
            todaysRoutines = [Routine]()
            return
        }

        todaysRoutines = allRoutines.filter { (routine) in
            WeekFlags.from(routine).setDays.map { (ordinalDay) in
                return ordinalDay.rawValue
            }.contains(today) && RoutineHelper.isFullyInitializedRoutine(routine)
        }
    }

    fileprivate func user() -> AWSCognitoIdentityUser {
        guard MyWayyService.shared.currentUser != nil else {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.logout()
            }

            // this should be irrelevant since the home screen gets
            // replaced by the login screen in the logout method
            return AWSCognitoIdentityUser()
        }

        return MyWayyService.shared.currentUser!
    }
  

    // MARK: UITableView Delegate and Data Source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HomeHeader") as! HomeHeader
        
          headerView.progressBar.setProgress(0.5, animated: true)
        headerView.numWays.text = "5"
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 186
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
       
         if indexPath.row == 0 || indexPath.row == 3{
         return 0.1
         }
         else if indexPath.row == 2{
            return 200
        }
        return 334
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier:"myTableCell") as! HomeRoutineItems
            
            cell.cellModels = cellModels
            cell.todaysRoutines = todaysRoutines
            return cell
        }
        else if indexPath.row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier:"myCell2") as! ComingRoutine
            
            return cell
        }
        else{

            let cell = tableView.dequeueReusableCell(withIdentifier:"myTableCell2") as! ComingRoutineItems
            cell.cellModels = cellModels
            cell.todaysRoutines = todaysRoutines
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Private

    fileprivate func createRoutine() {
        presentCreateRoutineScreen(routine: nil, routineTemplate: RoutineTemplate([String: Any]()), delegate: self)
    }
    
    fileprivate func createNewActivity() {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
         let vc = mainStoryboard.instantiateViewController(withIdentifier: "CustomActivityViewController") as? CustomActivityViewController
        self.present(vc!, animated: true, completion: nil)
    }

    fileprivate func logout() {
        (UIApplication.shared.delegate as? AppDelegate)?.logout()
    }

    fileprivate func presentActiveRoutineScreen(with routine: Routine) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ActiveRoutineViewController") as? ActiveRoutineViewController else {
            print("No routine or ActiveRoutineViewController!")
            return
        }
        vc.routine = routine
        vc.hidesBottomBarWhenPushed = true
        
        let customMapBar = storyboard!.instantiateViewController(withIdentifier: "CustomRoutineViewController") as! CustomRoutineViewController
        
        
        popupBar.customBarViewController = customMapBar
        popupContentView.popupCloseButtonStyle = .none
        popupInteractionStyle = .snap
        popupContentVC = vc
        
        DispatchQueue.main.async {
            self.presentPopupBar(withContentViewController: self.popupContentVC, animated: false, completion: nil)
        }
        
        
//        self.present(vc, animated: true, completion: nil)
    }
}

extension HomeScreenViewController: RoutineCreationDelegate {
    func didUpdate(routineModel: RoutineCreationViewModel?) {
        // Do nothing
    }

    func doneCreatingRoutine() {
        updateModel()
        dismiss(animated: true, completion: nil)
    }
}

////////////////////////////////////////////////////////////////////////////////

// Temporary/deubg code
extension HomeScreenViewController {
    private func subscribeExample() {
//        // make routine public
//        let routineTemplate = MyWayyService.shared.user?.getRoutineTemplateById(5)!
//        routineTemplate?.isPublic = true
//        MyWayyService.shared.updateRoutineTemplate(template: routineTemplate!, { (success, errors) in
//            var buffer = ""
//            MyWayyService.shared.user?.toString(&buffer)
//            print(buffer)
//        })

//        // create routine
//        let routineTemplate = MyWayyService.shared.user?.getRoutineTemplateById(5)!
//        var routineDictionary = [String:Any]()
//        routineDictionary["routineTemplate"] = routineTemplate?.id
//        routineDictionary["endTime"] = routineTemplate?.endTime
//        routineDictionary["sunday"] = routineTemplate?.sunday
//        routineDictionary["monday"] = routineTemplate?.monday
//        routineDictionary["tuesday"] = routineTemplate?.tuesday
//        routineDictionary["wednesday"] = routineTemplate?.wednesday
//        routineDictionary["thursday"] = routineTemplate?.thursday
//        routineDictionary["friday"] = routineTemplate?.friday
//        routineDictionary["saturday"] = routineTemplate?.saturday
//        routineDictionary["alertStyle"] = routineTemplate?.alertStyle
//        routineDictionary["reminder"] = routineTemplate?.reminder
//
//        let routine = Routine(routineDictionary)
//        MyWayyService.shared.createRoutine(routine, { (success, error) in
//            var buffer = ""
//            MyWayyService.shared.user?.toString(&buffer)
//            print(buffer)
//        })
    }

    @IBAction func showTestAlert(sender: UIButton?) {
        let alert = UIAlertController(title: "Test Access", message: "User: \(user().username ?? "")", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Create Wayy", style: .default, handler: { (action) in
            self.createRoutine()
        }))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Make Dummy", style: .default, handler: { (action) in
            self.createTestRoutine()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func createTestRoutine() {
        //        var activityTemplateFields00 = [String: Any]()
        //        activityTemplateFields00["profile"] = MyWayyService.shared.profile?.id
        //        activityTemplateFields00["name"] = "Make Pie"
        //        activityTemplateFields00["description"] = "Pie making process defined here."
        //        activityTemplateFields00["icon"] = "pie.png"
        //        activityTemplateFields00["duration"] = 80
        //        activityTemplateFields00["tags"] = "pie"
        //        let activityTemplate00 = ActivityTemplate(activityTemplateFields00)
        //
        //        MyWayyService.shared.createActivityTemplate(activityTemplate00, { (success, error) in
        //            if success {
        //                var activityTemplateFields01 = [String: Any]()
        //                activityTemplateFields01["profile"] = MyWayyService.shared.profile?.id
        //                activityTemplateFields01["name"] = "Eat Pie"
        //                activityTemplateFields01["description"] = "NOM NOM NOM NOM NOM NOM"
        //                activityTemplateFields01["icon"] = "pie_plate.png"
        //                activityTemplateFields01["duration"] = 15
        //                activityTemplateFields01["tags"] = "pie"
        //                let activityTemplate01 = ActivityTemplate(activityTemplateFields01)
        //
        //                MyWayyService.shared.createActivityTemplate(activityTemplate01, { (success, error) in
        //                    if success {
        //                        var routineTemplateFields00 = [String: Any]()
        //                        routineTemplateFields00["profile"] = MyWayyService.shared.profile?.id
        //                        routineTemplateFields00["name"] = "Pie Pie Pie"
        //                        routineTemplateFields00["description"] = "Making and consumption of pie."
        //                        routineTemplateFields00["image"] = "http://example.com/pie.jpg"
        //                        routineTemplateFields00["isPublic"] = true
        //                        routineTemplateFields00["endTime"] = "13:00:00"
        //                        routineTemplateFields00["sunday"] = true
        //                        routineTemplateFields00["monday"] = false
        //                        routineTemplateFields00["tuesday"] = false
        //                        routineTemplateFields00["wednesday"] = false
        //                        routineTemplateFields00["thursday"] = false
        //                        routineTemplateFields00["friday"] = false
        //                        routineTemplateFields00["saturday"] = false
        //                        routineTemplateFields00["alertStyle"] = AlertStyle.none.rawValue
        //                        routineTemplateFields00["reminder"] = "none"
        //                        routineTemplateFields00["tags"] = "pie"
        //                        let routineTemplate00 = RoutineTemplate(routineTemplateFields00)
        //
        //                        MyWayyService.shared.createRoutineTemplate(routineTemplate00, { (success, error) in
        //                            if success {
        //                                var routineTemplateActivityFields00 = [String: Any]()
        //                                routineTemplateActivityFields00["routineTemplate"] = routineTemplate00.id
        //                                routineTemplateActivityFields00["activityTemplate"] = activityTemplate00.id
        //                                routineTemplateActivityFields00["displayOrder"] = 1
        //                                let routineTemplateActivity00 = RoutineTemplateActivity(routineTemplateActivityFields00)
        //
        //                                MyWayyService.shared.createRoutineTemplateActivity(routineTemplateActivity00, { (success, errors) in
        //                                    if success {
        //                                        var routineTemplateActivityFields01 = [String: Any]()
        //                                        routineTemplateActivityFields01["routineTemplate"] = routineTemplate00.id
        //                                        routineTemplateActivityFields01["activityTemplate"] = activityTemplate01.id
        //                                        routineTemplateActivityFields01["displayOrder"] = 2
        //                                        let routineTemplateActivity01 = RoutineTemplateActivity(routineTemplateActivityFields01)
        //
        //                                        MyWayyService.shared.createRoutineTemplateActivity(routineTemplateActivity01, { (success, errors) in
        //                                            if success {
        //                                                var buffer = ""
        //                                                MyWayyService.shared.profile?.toString(&buffer)
        //                                                print("USER: \(buffer)")
        //                                            }
        //                                        })
        //                                    }
        //                                })
        //                            }
        //                        })
        //                    }
        //                })
        //            }
        //        })

        //        // CREATE shared routine from account aarond0121
        //        var routineFields = [String: Any]()
        //        routineFields["profile"] = MyWayyService.shared.profile?.id
        //        routineFields["routineTemplate"] = 7
        //        routineFields["endTime"] = "13:00:00"
        //        routineFields["sunday"] = true
        //        routineFields["monday"] = false
        //        routineFields["tuesday"] = false
        //        routineFields["wednesday"] = false
        //        routineFields["thursday"] = false
        //        routineFields["friday"] = false
        //        routineFields["saturday"] = false
        //        routineFields["alertStyle"] =  AlertStyle.none.rawValue
        //        routineFields["reminder"] = "none"
        //        let routine = Routine(routineFields)
        //
        //        MyWayyService.shared.createRoutine(routine, { (success, error) in
        //            if success {
        //                var buffer = ""
        //                MyWayyService.shared.profile?.toString(&buffer)
        //                print("USER: \(buffer)")
        //            }
        //        })

        //        // EXAMPLE: search routines
        //        MyWayyService.shared.searchRoutineTemplates(term: "%Pie%", limit: 20, offset: 0, { (success, results, error) in
        //            print("success: \(success)")
        //            if success {
        //                if let routineTemplates = results {
        //                    for value in routineTemplates.enumerated() {
        //                        let (_, routineTemplate) = value
        //                        var buffer = ""
        //                        routineTemplate.toString(&buffer)
        //                        print("routineTemplate: \(buffer)")
        //                    }
        //                }
        //            }
        //        })

        // EXAMPLE: search profiles
        MyWayyService.shared.searchProfiles(term: "%aaron%", limit: 20, offset: 0, { (success, results, error) in
            print("success: \(success)")
            if success {
                if let profiles = results {
                    profiles.forEach({ (profile) in
                        var buffer = ""
                        profile.toString(&buffer)
                        print("profile: \(buffer)")
                    })
                }
            }
        })
    }
}
