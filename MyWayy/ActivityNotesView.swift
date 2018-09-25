//
//  ActivityNotesView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/20/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class ActivityNotesView: ActivityCardView {
    static let nibName = String(describing: ActivityNotesView.self)

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private  weak var dividerView: UIView!
    @IBOutlet private weak var notesLabel: UILabel!
    @IBOutlet private weak var backToActivityButton: UIButton!

    var notes = "" {
        didSet {
            notesLabel.text = notes
        }
    }
    weak var toggleDelegate: NotesViewToggleDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.set(ActivityCardView.titleFont, ActivityCardView.titleColor)
        dividerView.backgroundColor = UIColor.with(Rgb(r: 178, g: 189, b: 204), Alpha.half)
        notesLabel.set(UIFont.medium(16), UIColor.with(Rgb(r: 34, g: 41, b: 51)))
        backToActivityButton.setTitleColor(UIColor.lightishBlueFullAlpha, for: .normal)
        backToActivityButton.titleLabel?.font = UIFont.heavy(10)
    }

    @IBAction func backToActivityTapped(_ sender: UIButton) {
        toggleDelegate?.toggleViews(animated: true)
    }
}
