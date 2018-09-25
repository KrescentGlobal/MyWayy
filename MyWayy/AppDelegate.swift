//
//  AppDelegate.swift
//  MyWayy
//
//  Created by SpinDance on 9/18/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit
import AWSCognito
import AWSCognitoIdentityProvider

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    fileprivate static let homeNavVcTabIndex = 1

    var window: UIWindow?
    private var isLoggedIn = false
    var tagValue : [String]!
    /// When app is launched from a notification, this indicates the routine associated with the notification.
    fileprivate var pendingRoutineInfo: RoutineNotificationInfo?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Making Navigation Bar transparent
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        LocalNotificationHandler.shared.registerAppForLocalNotifications()
        LocalNotificationHandler.shared.delegate = self        
        
//         UITabBar.appearance().selectionIndicatorImage = getImageWithColorPosition(color: UIColor.lightishBlueFullAlpha, size: CGSize(width:(self.window?.frame.size.width)!/4,height: 49), lineSize: CGSize(width:(self.window?.frame.size.width)!/4, height:3))
        
        UIApplication.shared.statusBarStyle = .lightContent
        // OPTION: super logging from AWS SDK
        // AWSDDLog.sharedInstance.logLevel = .verbose
        // AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        let firstScreen = (window?.rootViewController as? UINavigationController)?.topViewController
        firstScreen?.showOverlay()

        // attempt to log user in if someone was logged in
        // at the end of the last time the application ran
        return !MyWayyService.shared.login({ (user: AWSCognitoIdentityUser?, response: AWSCognitoIdentityUserSession?, nserror: NSError?) in
            firstScreen?.hideOverlay()

            if let error = nserror {
                // TODO: is logging user out the correct response, it may just
                // be a network issue which is preventing the user from logging
                // into the system.
                print("AppDelegate.applicationDidFinishLaunching: \(error)")
                self.logout()
            } else {
                print("AppDelegate.applicationDidFinishLaunching: \(response!)")
                self.login(user!)
            }
        })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        NotificationCenter.default.post(name: Notification.Name.appDidEnterBackground, object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        NotificationCenter.default.post(name: Notification.Name.appWillEnterForeground, object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if isLoggedIn {
            checkForRoutineToShow()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func getImageWithColorPosition(color: UIColor, size: CGSize, lineSize: CGSize) -> UIImage {
        let rect = CGRect(x:0, y: 0, width: size.width, height: size.height)
        let rectLine = CGRect(x:0, y:size.height-lineSize.height,width: lineSize.width,height: lineSize.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.setFill()
        UIRectFill(rect)
        color.setFill()
        UIRectFill(rectLine)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: user management

    func login(_ user: AWSCognitoIdentityUser) {
        isLoggedIn = true
        showHomeScreen()
        checkForRoutineToShow()
    }

    func logout() {
        MyWayyService.shared.logout()
        showLoginScreen()
        isLoggedIn = false
    }

    // MARK: show screens

    fileprivate func showLoginScreen() {
        if let vc = window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "WalkthroughViewController") {
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        } else {
            print("Error: unable to show LoginViewController")
        }
    }

    func promptUserForConfirmationCode(username: String?, password: String?) {
        
        if let vc = window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "CodeConfirmViewController") as? CodeConfirmViewController {
            vc.username = username
            vc.password = password
            vc.modalPresentationStyle = .popover
            window?.rootViewController?.present(vc, animated: true, completion: nil)
        } else {
            print("Error: unable to show CodeConfirmViewController")
        }
    }

    fileprivate func showHomeScreen() {
        if let vc = window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "SessionViewController") as? UITabBarController {
            window?.rootViewController = vc
            window?.makeKeyAndVisible()

            // Todo: Temporary - replace the home screen with the new version of it in its own storyboard.
            guard var vcs = vc.viewControllers, vcs.count > 0 else {
                logError()
                return
            }
            vcs[AppDelegate.homeNavVcTabIndex] = UIViewController.homeNavVc
            vc.selectedIndex = AppDelegate.homeNavVcTabIndex
            vc.setViewControllers(vcs, animated: false)
        } else {
            print("Error: unable to show HomeScreenViewController")
        }
    }

    /// Returns the id of a routine that is currently running, if any. Does not
    /// consider whether app is in foreground or not.
    fileprivate func activeRoutineId() -> Int? {
        guard
            let tabBarVc = window?.rootViewController as? UITabBarController,
            let homeNavVc = tabBarVc.selectedViewController as? UINavigationController,
            let activeRoutineVc = homeNavVc.topViewController as? ActiveRoutineViewController,
            let activeRoutineId = activeRoutineVc.routine?.id
        else {
            return nil
        }

        return activeRoutineId
    }

    /// Gets the (previously instantiated) home screen
    fileprivate func getHomeScreen() -> HomeScreenViewController? {
        guard
            let tabBarVc = window?.rootViewController as? UITabBarController,
            let homeNavVc = tabBarVc.viewControllers?[AppDelegate.homeNavVcTabIndex] as? UINavigationController,
            let homeVc = homeNavVc.topViewController as? HomeScreenViewController
            else {
                logError("Could not get home screen")
                return nil
        }
        return homeVc
    }

    fileprivate func checkForRoutineToShow() {
        guard pendingRoutineInfo == nil else {
            presentHomeScreen(with: pendingRoutineInfo!)
            pendingRoutineInfo = nil
            return
        }
    }

    /// Warning: This currently dismisses any screen that might currently be presented!
    fileprivate func presentHomeScreen(with routineInfo: RoutineNotificationInfo) {
        let showBlock = {
            guard let tabBarVc = self.window?.rootViewController as? UITabBarController else {
                logError()
                return
            }

            // Select the home screen tab
            tabBarVc.selectedIndex = AppDelegate.homeNavVcTabIndex
            // We start no routine before it's time (when minutesToStart is negative)
            guard routineInfo.minutesToStart >= 0 else {
                // Just show the Home screen
                return
            }

            guard let homeScreen = self.getHomeScreen() else {
                tabBarVc.showOkErrorAlert(message: NSLocalizedString("Error presenting Wayy", comment: ""))
                return
            }

            // Start the routine
            homeScreen.startRoutineWithId(routineInfo.routineId)
        }

        // Dismiss any modals
        if let presented = window?.rootViewController?.presentedViewController {
            presented.dismiss(animated: false, completion: showBlock)
        } else {
            showBlock()
        }
    }
}

extension AppDelegate: LocalNotificationResponseDelegate {
    func notificationArrivedForRoutine(_ notificationInfo: RoutineNotificationInfo) {
        guard shouldShowRoutineNotification() else {
            logDebug("Not showing notification for routineId \(notificationInfo.routineId) since routineId \(String(describing: activeRoutineId())) is already active and in the foreground.")
            return
        }

        switch UIApplication.shared.applicationState {
        case .active, .background:
            presentHomeScreen(with: notificationInfo)
            
        case .inactive:
            // Assume app is not active, and set routine ID for later
            pendingRoutineInfo = notificationInfo
        }
    }

    func shouldShowNotificationForRoutineId(_ routineId: Int) -> Bool {
        return shouldShowRoutineNotification()
    }

    private func shouldShowRoutineNotification() -> Bool {
        return (UIApplication.shared.applicationState != .active) || (activeRoutineId() == nil)
    }
}

