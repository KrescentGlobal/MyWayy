//
//  UIViewController+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/9/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

extension UIViewController {
    static var activeRoutine: UIViewController {
        return UIStoryboard.activeRoutine.instantiateViewController(withIdentifier: ActiveRoutineViewController.storyboardId)
    }

    static var homeNavVc: UIViewController {
        return UIStoryboard.home.instantiateViewController(withIdentifier: "HomeScreenNavigationController")
    }

    static var home: UIViewController {
        return UIStoryboard.home.instantiateViewController(withIdentifier: HomeScreenViewController.storyboardId)
    }

    static var completedRoutine: UIViewController {
        return UIStoryboard.activeRoutine.instantiateViewController(withIdentifier: CompletedRoutineViewController.storyboardId)
    }
    
    static var publicProfile: UIViewController {
        return UIStoryboard.publicProfile.instantiateViewController(withIdentifier: PublicProfileViewController.storyboardId)
    }

    static var editActivity: UIViewController {
        return UIStoryboard.editActivity.instantiateViewController(withIdentifier: EditActivityViewController.storyboardId)
    }
    
    static var options: UIViewController {
        return UIStoryboard.options.instantiateViewController(withIdentifier: OptionsViewController.storyboardId)
    }
    
    static var editProfile: UIViewController {
        return UIStoryboard.main.instantiateViewController(withIdentifier: EditProfileViewController.storyboardId)
    }

    static var publicRoutine: UIViewController {
        return UIStoryboard.publicRoutine.instantiateViewController(withIdentifier: PublicRoutineViewController.storyboardId)
    }

    static var publicRoutineSettingsPage: UIViewController {
        return UIStoryboard.publicRoutine.instantiateViewController(withIdentifier: PublicRoutineSettingsPageViewController.storyboardId)
    }

    static var publicRoutineActivitiesPage: UIViewController {
        return UIStoryboard.publicRoutine.instantiateViewController(withIdentifier: PublicRoutineActivitiesPageViewController.storyboardId)
    }

    static var createRoutine: UIViewController {
        return UIStoryboard.main.instantiateViewController(withIdentifier: CreateRoutineViewController.storyboardId)
    }

    static var addActivities: UIViewController {
        return UIStoryboard.main.instantiateViewController(withIdentifier: AddActivitiesViewController.storyboardId)
    }    

    static var resetPassword: UIViewController {
        return UIStoryboard.main.instantiateViewController(withIdentifier: ResetPasswordViewController.storyboardId)
    }
}

extension UIViewController {
    func presentCreateRoutineScreen(routine: Routine?, routineTemplate: RoutineTemplate?, delegate: RoutineCreationDelegate?) {
        guard let vc = UIViewController.createRoutine as? CreateRoutineViewController else {
            logError()
            return
        }

        vc.routineCreationDelegate = delegate
        vc.routineTemplate = routineTemplate
        vc.routine = routine
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navVc = storyboard.instantiateViewController(withIdentifier: "createRoutineNavigationBar") as! UINavigationController
        
        navVc.viewControllers = [vc]
        present(navVc, animated: true, completion: nil)
    }

    func showOverlay(with text: String = "") {
        guard let selfAsOverlayOwner = checkHasOverlay() else { return }
        selfAsOverlayOwner.overlay.show(in: view, text: text)
    }

    func hideOverlay() {
        guard let selfAsOverlayOwner = checkHasOverlay() else { return }
        selfAsOverlayOwner.overlay.hide()
    }

    /// If the current user owns this routine template, the public routine screen
    /// is presented showing information from the routine that has the specified
    /// routine template; otherwise the the public routine screen is presented
    /// showing information from the routine template
    func presentPublicRoutineScreen(withRoutineTemplate routineTemplate: RoutineTemplate?) {
        guard
            let thisRoutineTemplate = routineTemplate,
            let vc = UIViewController.publicRoutine as? PublicRoutineViewController,
            let userOwnsRoutineTemplate = MyWayyService.shared.currentUserOwns(routineTemplate: thisRoutineTemplate)
        else {
            logError()
            return
        }

        if !userOwnsRoutineTemplate {
            vc.routineTemplate = thisRoutineTemplate
        } else {
            guard let routine = RoutineHelper.findRoutine(with: thisRoutineTemplate) else {
                logError()
                return
            }
            vc.routine = routine
        }

        vc.userOwnsRoutine = userOwnsRoutineTemplate
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func presentPublicRoutineScreen(withRoutine routine: Routine?) {
        guard
            let thisRoutine = routine,
            let vc = UIViewController.publicRoutine as? PublicRoutineViewController,
            let userOwnsRoutine = MyWayyService.shared.currentUserOwns(routine: thisRoutine)
            
        else {
            logError()
            return
        }

        vc.userOwnsRoutine = userOwnsRoutine
        vc.routine = thisRoutine
       //  self.present(vc, animated: true, completion: nil)
     self.navigationController?.pushViewController(vc, animated: true)
    }

    private func checkHasOverlay() -> BusyOverlayOwner? {
        guard let overlayOwner = self as? BusyOverlayOwner else {
            logError("\(String(describing: self)) DOES NOT HAVE AN OVERLAY!")
            return nil
        }
        return overlayOwner
    }
    
    func getAndValidateEmailAndPhoneNumberEntry(emailField: UITextField?, phoneNumberField: UITextField?) -> EmailAndPhoneNumberEntry? {
        let entry = EmailAndPhoneNumberEntry(email: emailField?.text, phoneNumber: phoneNumberField?.text)

        guard entry.hasAtLeastOneEntry else {
            showRequiredPhoneNumberOrEmailAlert()
            return nil
        }

        // Atleast one has text... Now validate, if there's something there
        if entry.hasEmailEntry {
            guard entry.emailIsValid else {
                showInvalidEmailAlert()
                return nil
            }
        }

        if entry.hasPhoneNumberEntry {
            guard entry.phoneNumberIsValid else {
                showInvalidPhoneNumberAlert()
                return nil
            }
        }

        return entry
    }

    func showRequiredPhoneNumberOrEmailAlert() {
        let alertMessage = NSLocalizedString("createUserViewController.error.phoneNumberEmailRequired", comment: "Phone Number or Email required")
        showOkErrorAlert(message: alertMessage)
    }

    func showInvalidPhoneNumberAlert() {
        let alertMessage = NSLocalizedString("createUserViewController.error.invalidPhoneNumber", comment: "Phone Number entered is not valid")
        showOkErrorAlert(message: alertMessage)
    }

    func showInvalidEmailAlert() {
        let alertMessage = NSLocalizedString("createUserViewController.error.invalidEmail", comment: "Email entered is not valid")
        showOkErrorAlert(message: alertMessage)
    }
}
