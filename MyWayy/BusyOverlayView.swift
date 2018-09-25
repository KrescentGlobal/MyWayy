//
//  BusyOverlayView.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/15/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

protocol BusyOverlayOwner: class {
    var overlay: BusyOverlayView { get }
}

class BusyOverlayView: UIView {
    static let nibName = String(describing: BusyOverlayView.self)
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var label: UILabel!

    private struct OverlayDefaults {
        static let alpha: CGFloat = Alpha.half
        static let backgroundColor = UIColor.black
        static let font = UIFont.heavy(17)
        static let textColor = UIColor.white
        static let showHideDuration: TimeInterval = 0.25
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = OverlayDefaults.backgroundColor
        alpha = OverlayDefaults.alpha
        label.set(OverlayDefaults.font, OverlayDefaults.textColor)

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        addSubview(blurView)
        UIView.addMarginAnchorConstraints(from: self, to: blurView)
        sendSubview(toBack: blurView)
    }

    static func create() -> BusyOverlayView {
        return UIView.instance(from: nibName) as! BusyOverlayView
    }

    func show(in parentView: UIView, text: String = "") {
        label.text = text
        alpha = Alpha.none
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        spinner.startAnimating()
        UIView.addMarginAnchorConstraints(from: parentView, to: self)
        UIView.animate(withDuration: OverlayDefaults.showHideDuration) {
            self.alpha = OverlayDefaults.alpha
        }
    }

    func hide() {
        UIView.animate(withDuration: OverlayDefaults.showHideDuration, animations: {
            self.alpha = Alpha.none
        }) { (done) in
            self.spinner.stopAnimating()
            self.removeFromSuperview()
        }
    }
}
