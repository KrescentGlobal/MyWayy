//
//  DayIconCircleView.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/14/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class DayIconCircleView: UIView {

    var color = UIColor.lightishBlueFullAlpha
    var fontSize: CGFloat = 6
    var circleWidth: CGFloat = 1
    var day: OrdinalDay? {
        didSet {
            guard let d = day else { return }
            dayLabel.text = d.shortAbbreviatedDayString
        }
    }

    private var dayLabel: UILabel

    override init(frame: CGRect) {
        dayLabel = UILabel(frame: frame)
        super.init(frame: frame)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dayLabel)
        addCenterConstraints(from: dayLabel, to: self)
        dayLabel.set(UIFont.medium(fontSize), color)
        [self, dayLabel].forEach { $0.backgroundColor = .clear }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        layer.borderColor = color.cgColor
        layer.borderWidth = circleWidth
        layer.cornerRadius = frame.size.width / 2.0
    }

    func setSizeConstraints(width: CGFloat) {
        NSLayoutConstraint.activate([heightAnchor.constraint(equalToConstant: width),
                                     widthAnchor.constraint(equalToConstant: width)])
    }
}
