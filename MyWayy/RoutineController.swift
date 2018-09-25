//
//  RoutineController.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/9/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Speeds up the countdown timer for debugging purposes. Set to 1.0 to disable!
private let DEBUG_SPEED_UP_FACTOR = 1.0
////////////////////////////////////////////////////////////////////////////////

struct RoutineTimeResults {
    let startTime: Date
    let expectedEndTime: Date
    let actualEndTime: Date
    let actualDurationSec: TimeInterval
    let expectedDurationSec: TimeInterval
    let numActivities: Int
    let nextOccuranceDate: Date

    var middleTime: Date {
        return startTime.addingTimeInterval(actualDurationSec / 2.0)
    }
}

////////////////////////////////////////////////////////////////////////////////

protocol RoutineControllerDelegate {
    func secondsRemainingChanged(_ secondsRemaining: Int, for activity: Activity)
    func timerExpired(for activity: Activity)
    func activityAlertFired(alertStyle: AlertStyle, alertIndex: Int, minutesRemaining: UInt)
    func endTimeChanged(to date: Date)
    func skip(to activity: Activity, at index: Int)
    func routineCompletedInBackground()
}

////////////////////////////////////////////////////////////////////////////////

class RoutineController {
    // MARK: Public properties

    /// This is based off the duration of the routine and the time at which it is started
    let expectedEndTime: Date

    /// This property is a convenience that is used to track the current activity's
    /// duration, which can change when the user adds time to a running activity.
    private(set) var currentActivityDurationSeconds = 0
    private(set) var sortedActivities = [Activity]()
    fileprivate(set) var activitySecondsRemaining = 0
    var isRunning = false
    var secondsRemainingInRoutine: Int {
        var total = 0
        var startTotaling = false
        guard let current = currentActivity else { return total }

        for thisActivity in sortedActivities {
            if current.id == thisActivity.id {
                startTotaling = true
                total += activitySecondsRemaining
            } else if startTotaling {
                total += thisActivity.durationInSeconds ?? 0
            }
        }

        return total
    }
    var nextActivity: Activity? {
        let index = currentActivityIndex + 1
        return activityIndexIsValid(index) ? sortedActivities[index] : nil
    }

    // MARK: Private Properties

    /// This is based off expectedEndTime and then gets modified when the user
    /// pauses a routine or skips ahead before a given activity is complete.
    private var actualEndTime: Date {
        didSet {
            delegate?.endTimeChanged(to: actualEndTime)
        }
    }
    fileprivate var routine: Routine?
    fileprivate var currentActivityIndex = -1
    private let tickIntervalSec: Double = 1.0 / DEBUG_SPEED_UP_FACTOR

    /// This is used when the app has been in the background during a running activity,
    /// and we need to fire things back up as if the now new current activity is already
    /// running or is just starting. So the override is used to override
    /// activitySecondsRemaining when we start that new activity.
    fileprivate var activitySecondsRemainingOverride: Int?
    private var tickTimer: Timer?
    private var pausedTimeTimer: Timer?
    private var secondsPaused = 0
    fileprivate var delegate: RoutineControllerDelegate?
    private lazy var alertSchedule: AlertSchedule = {
        guard let alerts = self.routine?.reminder else {
            return AlertSchedule(scheduleString: "")
        }
        return AlertSchedule(scheduleString: alerts)
    }()
    fileprivate var currentActivity: Activity? {
        didSet {
            activitySecondsRemaining = currentActivity?.durationInSeconds ?? 0
            currentActivityDurationSeconds = activitySecondsRemaining
        }
    }

    // MARK: Public methods

    init(routine: Routine?, delegate: RoutineControllerDelegate?) {
        self.routine = routine
        self.delegate = delegate
        self.sortedActivities = routine?.sortedActivities() ?? [Activity]()
        self.activitySecondsRemaining = self.currentActivity?.durationInSeconds ?? 0
        let durationInSeconds = (routine?.duration() ?? 0) * Constants.secondsInMinute
        self.expectedEndTime = Date().addingTimeInterval(TimeInterval(durationInSeconds))
        self.actualEndTime = self.expectedEndTime

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppToBackground(notification:)),
                                               name: Notification.Name.appDidEnterBackground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppToForeground(notification:)),
                                               name: Notification.Name.appWillEnterForeground,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setNextActivity() -> Activity? {
        stopCurrentActivity(trackStoppedTime: false)

        // If we're skipping ahead, adjust the end time (make it earlier)
        if currentActivity != nil, activitySecondsRemaining > 0 {
            logDebug("Subtracting \(activitySecondsRemaining) sec from endTime")
            actualEndTime = actualEndTime.addingTimeInterval(TimeInterval(-activitySecondsRemaining))
        }

        currentActivityIndex += 1
        currentActivity = activityIndexIsValid(currentActivityIndex) ? sortedActivities[currentActivityIndex] : nil

        if let newSecondsRemaining = activitySecondsRemainingOverride {
            activitySecondsRemaining = newSecondsRemaining
            activitySecondsRemainingOverride = nil
        }

        return currentActivity
    }

    func startCurrentActivity() {
        guard
            let theRoutine = routine,
            let activity = currentActivity,
            !isRunning && activitySecondsRemaining > 0
        else {
            return
        }
        isRunning = true
        stopPausedTimer()
        startTickTimer(for: activity, in: theRoutine)
    }

    func stopCurrentActivity(trackStoppedTime: Bool) {
        isRunning = false
        stopTickTimer()

        if trackStoppedTime {
            startPausedTimer()
        }
    }

    func addMinutesToCurrentActivity(_ minutes: Int) {
        guard let activity = currentActivity, minutes != 0 else {
            return
        }
        let extraSeconds = minutes * Constants.secondsInMinute
        currentActivityDurationSeconds += extraSeconds
        activitySecondsRemaining += extraSeconds
        addTimeIntervalToEndTime(TimeInterval(extraSeconds))
        delegate?.secondsRemainingChanged(activitySecondsRemaining, for: activity)
    }

    func storeCompletionTimeDelta() {
        let delta = actualEndTime.timeIntervalSince(expectedEndTime)
        UserDefaults.set(latestCompletionDelta: Int(delta), for: routine?.getTemplate()?.id)
    }

    func getTimeResults() -> RoutineTimeResults? {
        guard let r = routine else {
                logError()
                return nil
        }

        let expectedDuration = TimeInterval(r.duration() * Constants.secondsInMinute)
        let startTime = expectedEndTime.addingTimeInterval(-expectedDuration)
        let actualDuration = actualEndTime.timeIntervalSince(startTime)

        guard actualDuration > 0 else {
            logError("Invalid total \(actualDuration)!")
            return nil
        }
        guard let nextDate = r.getNextScheduledDate() else {
            logError()
            return nil
        }

        return RoutineTimeResults(startTime: startTime,
                                  expectedEndTime: expectedEndTime,
                                  actualEndTime: actualEndTime,
                                  actualDurationSec: actualDuration,
                                  expectedDurationSec: expectedDuration,
                                  numActivities: sortedActivities.count,
                                  nextOccuranceDate: nextDate)
    }

    func storeTotalTimeInRoutine() {
        guard let r = routine, let results = getTimeResults() else {
            logError("Could not calculate time results")
            return
        }
        guard let profile = r.getTemplate()?.getProfile() else {
            logError()
            return
        }
        let minutes = Int(round(results.actualDurationSec / TimeInterval(Constants.secondsInMinute)))
        profile.totalRoutineMinutes = (profile.totalRoutineMinutes ?? 0) + minutes

        MyWayyService.shared.updateProfile { (success, error) in
            guard success else {
                logError("updateProfile failed with error: \(String(describing: error))")
                return
            }
            logDebug("profile.totalRoutineMinutes updated to \(String(describing: profile.totalRoutineMinutes))")
        }
    }

    // MARK: Private methods

    private func activityIndexIsValid(_ index: Int) -> Bool {
        return (index >= 0) && (index < sortedActivities.count)
    }

    private func addTimeIntervalToEndTime(_ timeInterval: TimeInterval) {
        actualEndTime = actualEndTime.addingTimeInterval(timeInterval)
    }

    // MARK: Private timer start/stop methods

    private func startTickTimer(for activity: Activity, in routine: Routine) {
        DispatchQueue.main.async {
            logDebug("Start tracking running time")
            self.tickTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.tickIntervalSec), repeats: true) { (timer) in
                self.activitySecondsRemaining -= Int(max(self.tickIntervalSec, 1))
                self.delegate?.secondsRemainingChanged(self.activitySecondsRemaining, for: activity)

                if self.activitySecondsRemaining > 0 {
                    let tuple = self.alertSchedule.hasScheduleEntry(at: UInt(self.activitySecondsRemaining))
                    let hasEntry = tuple.0
                    let entryIndex = tuple.1
                    if hasEntry {
                        let minutes = UInt(self.activitySecondsRemaining / Constants.secondsInMinute)
                        self.delegate?.activityAlertFired(alertStyle: routine.getAlertStyle(),
                                                          alertIndex: entryIndex,
                                                          minutesRemaining: minutes)
                    }
                } else {
                    self.delegate?.timerExpired(for: activity)
                    self.stopCurrentActivity(trackStoppedTime: false)
                }
            }
        }
    }

    private func stopTickTimer() {
        guard let t = tickTimer, t.isValid else { return }
        logDebug("Stop tracking running time")
        tickTimer?.invalidate()
        tickTimer = nil
    }

    private func startPausedTimer() {
        secondsPaused = 0
        DispatchQueue.main.async {
            logDebug("Start tracking paused time")
            self.pausedTimeTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.tickIntervalSec), repeats: true, block: { (timer) in
                self.secondsPaused += Int(self.tickIntervalSec * DEBUG_SPEED_UP_FACTOR)
            })
        }
    }

    private func stopPausedTimer() {
        guard let t = pausedTimeTimer, t.isValid else { return }
        logDebug("Stop tracking paused time. Paused \(secondsPaused) sec")
        pausedTimeTimer?.invalidate()
        pausedTimeTimer = nil
        addTimeIntervalToEndTime(TimeInterval(secondsPaused))
        secondsPaused = 0
    }
}

/// Activity description helpers
extension RoutineController {
    var activityIndexDescription: String {
        guard sortedActivities.count > 0 else {
            return NSLocalizedString("No Activities", comment: "")
        }
        return NSLocalizedString("\(currentActivityIndex + 1) OF \(sortedActivities.count) ACTIVITIES", comment: "")
    }
}

/// Background/foreground notification handling
extension RoutineController {
    // This method is admittedly complex, but it doesn't seem to make sense to
    // refactor it into multiple methods.
    @objc func handleAppToForeground(notification: Notification) {
        // Do nothing if not running
        guard isRunning else { return }

        // Figure out where we're at timewise with regard to the current activity
        guard
            let r = routine,
            let activity = currentActivity,
            let backgroundedDate = UserDefaults.getBackgroundedTime(for: r.id)
        else {
            logError()
            return
        }

        var secondsInBackground = Int(Date().timeIntervalSince(backgroundedDate))

        logDebug("Returning to foreground during active routine after \(secondsInBackground) sec...")

        guard secondsInBackground < secondsRemainingInRoutine else {
            logDebug("...Routine completed while backgrounded")
            delegate?.routineCompletedInBackground()
            return
        }

        guard secondsInBackground > activitySecondsRemaining else {
            // The backgrounded time fell within the current activity's duration,
            // so just notify the delegate and return.
            activitySecondsRemaining -= secondsInBackground
            delegate?.secondsRemainingChanged(activitySecondsRemaining, for: activity)
            let name = activity.getTemplate()?.name ?? ""
            logDebug("...Foregrounded during current activity '\(name)' with \(activitySecondsRemaining) sec remaining")

            if activitySecondsRemaining == 0 {
                delegate?.timerExpired(for: activity)
                stopCurrentActivity(trackStoppedTime: false)
            }
            return
        }

        // The current activity has completed while the app was in the background.
        // Determine what activity we should move to. Or, perhaps the whole routine
        // is over. "Use up" secondsInBackground to account for the now completed
        // current activity
        secondsInBackground -= activitySecondsRemaining

        // Find the next activity, then continue "using up" secondsInBackground to
        // account for activities that, in theory, kept running in the background.
        var startUsingUp = false
        var lastCheckedActivity = activity
        for (index, thisActivity) in sortedActivities.enumerated() {
            guard startUsingUp else {
                startUsingUp = activity.id == thisActivity.id
                continue
            }

            let thisActivityDuration = thisActivity.durationInSeconds ?? 0
            guard thisActivityDuration < secondsInBackground else {
                // All done: The routine is not over, and thisActivity is still
                // running. Update the state variables and notify the delegate of
                // the new current activity.

                // currentActivity and currentActivityIndex are both set to the
                // activity *before* thisActivity, since the delegate's "skip"
                // actions (called below) will cause a skip ahead to the next
                // activity after the "current" one.
                currentActivity = lastCheckedActivity
                currentActivityIndex = index - 1

                // Note: Set activitySecondsRemaining after adjusting currentActivity
                // because the latter updates the former.
                // Setting the remaining secs to 0 and then using the override
                // is a little trick to handle "starting" an activity that is
                // partially complete.
                activitySecondsRemaining = 0
                activitySecondsRemainingOverride = thisActivityDuration - secondsInBackground

                delegate?.skip(to: thisActivity, at: index)
                let name = thisActivity.getTemplate()?.name ?? ""
                logDebug("...Foregrounded during subsequent activity '\(name)' with \(activitySecondsRemaining) sec remaining")
                return
            }

            // "Use up" thisActivity's duration
            secondsInBackground -= thisActivityDuration
            lastCheckedActivity = thisActivity
        }

        logError("Shouldn't get here! (\(secondsInBackground)")
        delegate?.routineCompletedInBackground()
    }

    @objc func handleAppToBackground(notification: Notification) {
        guard isRunning else { return }

        let name = currentActivity?.getTemplate()?.name ?? ""
        logDebug("Backgrounded during current activity '\(name)' with \(activitySecondsRemaining) sec remaining")

        UserDefaults.set(backgroundedTime: Date(), for: routine?.id)
    }
}
