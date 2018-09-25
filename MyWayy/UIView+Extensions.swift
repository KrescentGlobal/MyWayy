//
//  UIView+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/9/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    static func instance(from nibName: String) -> UIView {
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    func addRoundedMyWayyShadow(radius: CGFloat) {
        layer.masksToBounds = false
        layer.cornerRadius = radius
        layer.shadowRadius = layer.cornerRadius
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = Float(Alpha.shadowLow)
        layer.shadowColor = UIColor.black.cgColor
    }

    static func addMarginAnchorConstraints(from parentView: UIView, to childView: UIView) {
        childView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            (parentView.leadingAnchor.constraint(equalTo: childView.leadingAnchor)),
            (parentView.trailingAnchor.constraint(equalTo: childView.trailingAnchor)),
            (parentView.topAnchor.constraint(equalTo: childView.topAnchor)),
            (parentView.bottomAnchor.constraint(equalTo: childView.bottomAnchor))])
    }

    func addMarginConstraints(from childView: UIView,
                              to parentView: UIView,
                              margin: CGFloat,
                              priority: UILayoutPriority = UILayoutPriority.required) {
        let top = NSLayoutConstraint(item: childView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: parentView,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: margin)
        let bottom = NSLayoutConstraint(item: childView,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: parentView,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: margin)
        let right = NSLayoutConstraint(item: childView,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: parentView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: margin)
        let left = NSLayoutConstraint(item: childView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: parentView,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: margin)
        [top, bottom, left, right].forEach {
            $0.priority = priority
        }

        addConstraint(top)
        addConstraint(bottom)
        addConstraint(right)
        addConstraint(left)
    }

    func addCenterXConstraints(from childView: UIView, to parentView: UIView) {
        childView.centerXAnchor.constraint(equalTo: parentView.layoutMarginsGuide.centerXAnchor).isActive = true
    }

    func addCenterYConstraints(from childView: UIView, to parentView: UIView) {
        childView.centerYAnchor.constraint(equalTo: parentView.layoutMarginsGuide.centerYAnchor).isActive = true
    }

    func addCenterConstraints(from childView: UIView, to parentView: UIView) {
        addCenterXConstraints(from: childView, to: parentView)
        addCenterYConstraints(from: childView, to: parentView)
    }
    
    func addBlurToBackground(view: UIView, blurView: UIVisualEffectView) {
        blurView.frame = view.bounds
        blurView.alpha = 0.75
        view.addSubview(blurView)
    }
    
    func removeBlurToBackground(view: UIView, blurView: UIVisualEffectView) {
        blurView.removeFromSuperview()
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
}
