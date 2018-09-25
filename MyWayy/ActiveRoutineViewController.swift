//
//  ActiveRoutineViewController.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/9/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class ActiveRoutineViewController: UIViewController {
    static let storyboardId = String(describing: ActiveRoutineViewController.self)

    var routine: Routine? {
        didSet {
            guard let r = routine else { return }
            routineController = RoutineController(routine: r, delegate: self)

            // For testing purposes
            //r.reminder = "79, 77, 75, 73, 71, 69, 67, 65, 63, 13, 11, 9, 5"
            //r.alertStyle = AlertStyle.voicePlusTones.rawValue
            //r.activities = [r.activities[0], r.activities[1], r.activities[0], r.activities[1], r.activities[0], r.activities[1]]
        }
    }
    @IBOutlet fileprivate weak var navBar: UINavigationBar!
    @IBOutlet fileprivate weak var endTimeLabel: UILabel!
    @IBOutlet fileprivate weak var activitiesStatusLabel: UILabel!
    @IBOutlet fileprivate weak var tapInstructionsLabel: UILabel!
    @IBOutlet fileprivate weak var nextActivityContainer: UIView!
    @IBOutlet fileprivate weak var scrollView: UIScrollView!

    // MARK: Next activity UI
    @IBOutlet fileprivate weak var nextActivityNameLabel: UILabel!
    @IBOutlet fileprivate weak var nextActivityDurationLabel: UILabel!
    @IBOutlet fileprivate weak var nextActivityIcon: UIImageView!
    @IBOutlet fileprivate weak var nextButton: UIButton!

    // MARK: Progress UI
    @IBOutlet fileprivate weak var progressView: ActivityProgressView!
    @IBOutlet fileprivate weak var progressStartIcon: UIImageView!
    @IBOutlet fileprivate weak var progressEndIcon: UIImageView!
    @IBOutlet fileprivate weak var alertScheduleView: AlertScheduleView?

    fileprivate var routineController = RoutineController(routine: nil, delegate: nil)
    fileprivate var currentPageView: ActivityPageContentView?
    fileprivate var progress: Progress?
    fileprivate var toastView: ToastView?
    fileprivate var settingsView: ActiveRoutineSettingsView?
    fileprivate lazy var pageManager: PagedScrollViewManager = {
        return PagedScrollViewManager(scrollView: self.scrollView, delegate: self)
    }()

    fileprivate var alertsEnabled = true
    fileprivate var currentPage = 0
    fileprivate var isSwiping = false
    fileprivate var numPages: Int { return routineController.sortedActivities.count }
    fileprivate let overlayTransitionDelegate = OverlayTransitionDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.topItem?.title = (routine?.getTemplate()?.name ?? NSLocalizedString("Unknown", comment: "")).uppercased()
        setStyle()
        toastView = ToastView.addToastView(to: self)
        settingsView = ActiveRoutineSettingsView.add(to: self)
        settingsView?.delegate = self
        alertScheduleView?.alertSchedule = AlertSchedule(scheduleString: routine?.reminder)

        // This has ended up being just a placeholder view for layout purposes.
        progressEndIcon.image = nil

        pageManager.initialize()
        pageManager.scrollLeftOnly = true
        guard let page0 = pageManager.pageContentView(at: 0) as? ActivityPageContentView else {
            logError()
            return
        }
        currentPageView = page0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEndTimeUi(with: routineController.expectedEndTime)
        setupNextActivity()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        routineController.startCurrentActivity()
        pageManager.adjustScrollViewContentSize()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SoundPlayer.shared.stop()
    }

    @IBAction func closeTapped(_ sender: UIBarButtonItem?) {
        performDoneActions(withDoneUx: false)
//        navigationController?.popViewController(animated: true)
    self.dismiss(animated: true, completion: nil)
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        goToPageOrBeDone(currentPage + 1)
    }

    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        settingsView?.set(hidden: false)
    }

    private func setStyle() {
        navBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.heavy(12),
                                      NSAttributedStringKey.foregroundColor: UIColor.with(Rgb.mediumGray, Alpha.full)]
        navBar.tintColor = UIColor.activeRoutineSettingsText

        [nextActivityNameLabel, nextActivityDurationLabel, nextButton.titleLabel!].forEach {
            $0.font = UIFont.heavy(15)
        }

        nextActivityContainer.layer.masksToBounds = false
        nextActivityContainer.layer.shadowOffset = CGSize(width: 0, height: -6)
        nextActivityContainer.layer.shadowOpacity = Float(Alpha.medium)
        nextActivityContainer.layer.shadowColor = UIColor.init(white: 0, alpha: Alpha.shadowLow).cgColor

        setNextActivityStyle(isNextActivity: true)

        endTimeLabel.set(UIFont.heavy(12), UIColor.with(Rgb.gray, Alpha.high))
        activitiesStatusLabel.set(UIFont.heavy(12), UIColor.with(Rgb.gray, Alpha.high))
        tapInstructionsLabel.set(UIFont.heavy(10), UIColor.with(Rgb.gray, Alpha.half))
    }
}

// MARK: ActiveActivityViewDelegate

extension ActiveRoutineViewController: ActiveActivityViewDelegate {
    func userSingleTapped(_ activityView: ActiveActivityView) {
        guard activityView == currentPageView?.activityView else { return }

        if routineController.isRunning {
            SoundPlayer.shared.play(soundAsset: .pause)
            routineController.stopCurrentActivity(trackStoppedTime: true)
        } else {
            SoundPlayer.shared.play(soundAsset: .resume)
            routineController.startCurrentActivity()
        }
        activityView.paused = !routineController.isRunning
    }

    func userDoubleTapped(_ activityView: ActiveActivityView) {
        guard activityView == currentPageView?.activityView else { return }

        if routineController.isRunning {
            SoundPlayer.shared.play(soundAsset: .addTime)

            // Update the routineController's activity duration first
            let minutesToAdd = MyWayy.activeRoutineExtensionMinutes
            routineController.addMinutesToCurrentActivity(minutesToAdd)

            // Then update the alert schedule view
            alertScheduleView?.add(minutesToAdd, secondsRemaining: routineController.activitySecondsRemaining)
        }
    }
}

// MARK: RoutineControllerDelegate

extension ActiveRoutineViewController: RoutineControllerDelegate {
    func secondsRemainingChanged(_ secondsRemaining: Int, for activity: Activity) {
        logDebug("\(secondsRemaining) sec remaining in '\(activity.getTemplate()?.name ?? "")'")
        currentPageView?.secondsRemaining = secondsRemaining
        progress?.totalUnitCount = Int64(routineController.currentActivityDurationSeconds)
        progress?.completedUnitCount = Int64(routineController.currentActivityDurationSeconds - secondsRemaining)
    }

    func timerExpired(for activity: Activity) {
        goToPageOrBeDone(currentPage + 1, playActivityComplete: true)
    }

    func activityAlertFired(alertStyle: AlertStyle, alertIndex: Int, minutesRemaining: UInt) {
        logTrace()
        alertScheduleView?.alertFired(at: minutesRemaining)
        guard alertsEnabled else { return }
        toastView?.show(title: NSLocalizedString("ALERT", comment: ""), minutesRemaining: minutesRemaining)
        SoundPlayer.shared.playAlert(with: alertStyle,
                                     alertIndex: alertIndex,
                                     minutesRemaining: minutesRemaining)
    }

    func endTimeChanged(to date: Date) {
        logDebug("New endTime: \(DateFormatter.timeFormatter.string(from: date))")
        updateEndTimeUi(with: date)
    }

    func skip(to activity: Activity, at index: Int) {
        logTrace()
        goToPageOrBeDone(index)
    }

    func routineCompletedInBackground() {
        logTrace()
        let outOfRangePage = routineController.sortedActivities.count
        goToPageOrBeDone(outOfRangePage)
    }
}

// MARK: PagedScrollViewManagerDelegate

extension ActiveRoutineViewController: PagedScrollViewManagerDelegate {
    func numberOfPages(for manager: PagedScrollViewManager) -> Int {
        return Int(max(numPages, 0))
    }

    func manager(_ manager: PagedScrollViewManager,
                 contentViewForPageAt index: Int) -> UIView {
        let pageContent = ActivityPageContentView(frame: .zero)
        pageContent.delegate = self
        pageContent.activity = routineController.sortedActivities[index]
        return pageContent
    }

    func manager(_ manager: PagedScrollViewManager,
                 scrolledToPageAt index: Int,
                 with pageContentView: UIView) {
        guard index != currentPage else { return }

        toastView?.hide()
        currentPage = index
        setupNextActivity()
        routineController.startCurrentActivity()
        currentPageView?.secondsRemaining = 0

        guard let view = pageContentView as? ActivityPageContentView else {
            logError()
            return
        }
        currentPageView = view
    }
}

// MARK: ActiveRoutineSettingsDelegate

extension ActiveRoutineViewController: ActiveRoutineSettingsDelegate {
    func setAlertNotifications(to enabled: Bool) {
        alertsEnabled = enabled
    }

    func stopRoutine() {
        closeTapped(nil)
    }

    func viewRoutineProfile() {
        presentPublicRoutineScreen(withRoutine: routine)        
    }

    func shareRoutine() {
        // Do nothing, sharing is currently not supported.
    }
}

// MARK: Helper methods

extension ActiveRoutineViewController {
    fileprivate func setupNextActivity() {
        guard let activity = routineController.setNextActivity() else {
            logError()
            return
        }

        alertScheduleView?.activityDuration = activity.duration ?? 0

        var nextActivity: Activity? = routineController.nextActivity

        // Next activity name and duration labels
        if let next = nextActivity, let name = next.getTemplate()?.name {
            nextActivityNameLabel.text = name
            nextActivityDurationLabel.text = ElapsedTimePresenter(seconds: next.durationInSeconds ?? 0).hoursAndMinutesStringShort
            nextActivity = next
        } else {
            nextActivityNameLabel.text = NSLocalizedString("No more activities", comment: "")
            nextActivityDurationLabel.text = ""
        }

        setNextActivityStyle(isNextActivity: nextActivity != nil)
        updateIcons(for: activity, next: nextActivity)

        progress = Progress(totalUnitCount: Int64(routineController.currentActivityDurationSeconds))
        progressView.observedProgress = progress
        activitiesStatusLabel.text = routineController.activityIndexDescription
    }

    fileprivate func setNextActivityStyle(isNextActivity: Bool) {
        nextActivityNameLabel.textColor = isNextActivity ? UIColor.lightishBlueHighAlpha : .white
        nextActivityDurationLabel.textColor = isNextActivity ? UIColor.lightishBlueMediumAlpha: .white
        nextButton.setTitleColor(nextActivityNameLabel.textColor, for: .normal)
        let nextTitle = isNextActivity ? NSLocalizedString("Next", comment: "") : NSLocalizedString("Finish", comment: "")
        nextButton.setTitle(nextTitle, for: .normal)
        nextActivityContainer.backgroundColor = isNextActivity ? UIColor.white : UIColor.lightishBlueFullAlpha
        nextButton.titleLabel?.sizeToFit()
    }

    private func updateIcons(for activity: Activity, next: Activity?) {
        let defaultImage = UIImage(named: "group3")

        if let thisIcon = activity.getTemplate()?.icon, let image = UIImage(named: thisIcon) {
            progressStartIcon.image = image
        } else {
            progressStartIcon.image = defaultImage
        }

        if let nextActivity = next {
            if let nextIcon = nextActivity.getTemplate()?.icon, let image = UIImage(named: nextIcon) {
                nextActivityIcon.image = image
            } else {
                nextActivityIcon.image = defaultImage
            }
        } else {
            nextActivityIcon.image = UIImage(named: "celebration white")
        }
    }

    fileprivate func updateEndTimeUi(with date: Date?) {
        guard let endTime = date else {
            logError("No endTime")
            endTimeLabel.text = ""
            return
        }
        endTimeLabel.text = NSLocalizedString("\(DateFormatter.timeFormatter.string(from: endTime)) END TIME", comment: "")
    }

    fileprivate func goToPageOrBeDone(_ targetPage: Int, playActivityComplete: Bool = false) {
        guard targetPage < numPages else {
            performDoneActions()
            presentDoneScreenAfterDelay()
            return
        }

        if playActivityComplete {
            SoundPlayer.shared.play(soundAsset: .activityComplete)
        }

        pageManager.gotoPage(page: targetPage, animated: true)
    }

    fileprivate func presentDoneScreenAfterDelay() {
        // Once we show the done screen, don't allow it to be shown again via
        // the next/finish button
        nextButton.isEnabled = false
        nextButton.alpha = Alpha.medium

        guard
            let vc = UIViewController.completedRoutine as? CompletedRoutineViewController,
            let results = routineController.getTimeResults()
        else {
            logError()
            return
        }
        vc.transitioningDelegate = overlayTransitionDelegate
        vc.routineResults = results
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.present(vc, animated: true)
        }
    }

    fileprivate func performDoneActions(withDoneUx: Bool = true) {
        routineController.stopCurrentActivity(trackStoppedTime: false)
        routineController.storeCompletionTimeDelta()
        routineController.storeTotalTimeInRoutine()

        if withDoneUx {
            SoundPlayer.shared.play(soundAsset: .done)
            currentPageView?.secondsRemaining = 0
        }
    }
}
