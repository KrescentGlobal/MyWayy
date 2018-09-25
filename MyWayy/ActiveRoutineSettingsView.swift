//
//  ActiveRoutineSettingsView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/26/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

protocol ActiveRoutineSettingsDelegate: class {
    func setAlertNotifications(to enabled: Bool)
    func stopRoutine()
    func viewRoutineProfile()
    func shareRoutine()
}

class ActiveRoutineSettingsView: VerticalConstraintHideableView {
    static let nibName = String(describing: ActiveRoutineSettingsView.self)

    weak var delegate: ActiveRoutineSettingsDelegate?

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var alertLabel: UILabel!
    @IBOutlet private weak var stopButton: UIButton!
    @IBOutlet private weak var profileButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var alertSwitch: UISwitch!

    @IBOutlet var dividerViews: [UIView]!

    static func add(to vc: UIViewController) -> ActiveRoutineSettingsView {
        let instance = UIView.instance(from: ActiveRoutineSettingsView.nibName) as! ActiveRoutineSettingsView
        instance.add(to: vc.view)
        return instance
    }

    override func awakeFromNib() {
        blockParentView = true
        screenLocation = .bottom
        super.awakeFromNib()

        titleLabel.set(UIFont.heavy(10), UIColor.with(Rgb.routineCellDarkGray))
        titleLabel.backgroundColor = UIColor.paleBlue
        alertLabel.set(UIFont.activeRoutineSettings, UIColor.activeRoutineSettingsText)
        alertSwitch.onTintColor = UIColor.lightishBlueFullAlpha
        alertSwitch.isOn = true
        [stopButton, profileButton, shareButton, cancelButton].forEach {
            $0?.setTitleColor(UIColor.activeRoutineSettingsText, for: .normal)
            $0?.titleLabel?.font = UIFont.activeRoutineSettings
        }
        dividerViews.forEach {
            $0.backgroundColor = titleLabel.backgroundColor
        }
    }

    @IBAction private func alertSwitchChanged(_ sender: UISwitch) {
        delegate?.setAlertNotifications(to: sender.isOn)
    }

    @IBAction private func stopTapped(_ sender: UIButton) {
        delegate?.stopRoutine()
    }

    @IBAction private func profileTapped(_ sender: UIButton) {
        delegate?.viewRoutineProfile()
    }

    @IBAction private func shareTapped(_ sender: UIButton) {
        // This UI is currently hidden, left in place in case we add the functionality later.
        delegate?.shareRoutine()
    }
}
