//
//  ToastView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/21/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class ToastView: VerticalConstraintHideableView {
    static let nibName = String(describing: ToastView.self)

    var showDurationSec = TimeInterval(4)
    private var title = "" { didSet { titleLabel.text = title } }
    private var message = "" { didSet { messageLabel.text = message.count == 0 ? "" : "\"\(message)\"" } }
    private var attributedMessage = NSAttributedString(string: "") {
        didSet {
            guard attributedMessage.length > 0 else {
                messageLabel.text = ""
                return
            }
            let quote = NSAttributedString(string: "\"")
            let string = NSMutableAttributedString()
            string.append(quote)
            string.append(attributedMessage)
            string.append(quote)
            messageLabel.attributedText = string
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    private var timer: Timer?

    static func addToastView(to vc: UIViewController) -> ToastView {
        let toast = UIView.instance(from: ToastView.nibName) as! ToastView
        toast.add(to: vc.view)
        return toast
    }

    override func awakeFromNib() {
        screenLocation = .top
        super.awakeFromNib()
    }

    func show(title: String, minutesRemaining: UInt, autohide: Bool = true) {
        show(title: title, attributedMessage: ElapsedTimePresenter.attributedTimeRemainingString(for: minutesRemaining))
    }

    func show(title: String, message: String?, autohide: Bool = true) {
        self.title = title
        self.message = message ?? ""
        show(autohide: autohide)
    }

    func show(title: String, attributedMessage: NSAttributedString, autohide: Bool = true) {
        self.title = title
        self.attributedMessage = attributedMessage
        show(autohide: autohide)
    }

    func show(autohide: Bool = true) {
        set(hidden: false)

        if autohide {
            timer = Timer.scheduledTimer(withTimeInterval: showDurationSec, repeats: false, block: { (timer) in
                self.hide()
            })
        }
    }

    func hide() {
        timer?.invalidate()
        set(hidden: true)
    }

    private func setActiveActivityStyle() {
        backgroundColor = UIColor.lightishBlueFullAlpha
        addRoundedMyWayyShadow(radius: 4)
        titleLabel.set(UIFont.heavy(12), UIColor.white)
        messageLabel.set(UIFont.book(14), UIColor.white)
    }
}
