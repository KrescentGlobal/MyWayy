//
//  OverlayTransitionDelegate.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/6/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

private struct OverlayConstants {
    static let initialScale: CGFloat = 0.5
    static let transitionDuration: TimeInterval = 0.2
    static let damping: CGFloat = 1.0
    static let springVelocity: CGFloat = 1.0
    static let alphaWhilePresented: CGFloat = 1.0
}

class OverlayTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    // chromeView is a shaded transparent full screen view that appears behind the overlay VC.
    let chromeView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.shadedOverlayBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let vc = OverlayPresentationAnimationController()
        vc.chromeView = chromeView
        return vc
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let vc = OverlayDismissalAnimationController()
        vc.chromeView = chromeView
        return vc
    }
}

////////////////////////////////////////////////////////////////////////////////

class BaseOverlayAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var chromeView = UIView(frame: .zero)

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return OverlayConstants.transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        logError("Should override")
    }
}

////////////////////////////////////////////////////////////////////////////////

class OverlayPresentationAnimationController: BaseOverlayAnimationController {
    var sideInset: CGFloat = 20
    var bottomInset: CGFloat = 100
    var topInset: CGFloat = 100
    var minimumHeight: CGFloat = 346

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVc = transitionContext.viewController(forKey: .to),
            let fromVc = transitionContext.viewController(forKey: .from)
        else {
            logError()
            return
        }

        // Add chromeView on top of the presenting VC
        chromeView.alpha = Alpha.none
        fromVc.view.addSubview(chromeView)
        fromVc.view.addMarginConstraints(from: fromVc.view, to: chromeView, margin: 0)
        fromVc.view.bringSubview(toFront: chromeView)

        if (toVc.view.bounds.size.height - bottomInset - topInset) < minimumHeight {
            topInset = toVc.view.bounds.size.height - minimumHeight - bottomInset
        }

        toVc.view.frame = UIEdgeInsetsInsetRect(transitionContext.containerView.bounds, UIEdgeInsetsMake(topInset, sideInset, bottomInset, sideInset));
        toVc.view.alpha = Alpha.none
        toVc.view.transform = CGAffineTransform(scaleX: OverlayConstants.initialScale, y: OverlayConstants.initialScale)

        transitionContext.containerView.addSubview(toVc.view)

        // Adjust alpha quickly
        UIView.animate(withDuration: OverlayConstants.transitionDuration * 0.5) {
            self.chromeView.alpha = Alpha.full
            toVc.view.alpha = OverlayConstants.alphaWhilePresented
        }

        // Adjust scale more slowly
        UIView.animate(withDuration: OverlayConstants.transitionDuration,
                       delay: 0,
                       usingSpringWithDamping: OverlayConstants.damping,
                       initialSpringVelocity: OverlayConstants.springVelocity,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
            toVc.view.transform = .identity
        }) { (finished) in
            transitionContext.completeTransition(true)
        }
    }
}

////////////////////////////////////////////////////////////////////////////////

class OverlayDismissalAnimationController: BaseOverlayAnimationController {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVc = transitionContext.viewController(forKey: .from)

        // Adjust alpha quickly
        UIView.animate(withDuration: OverlayConstants.transitionDuration * 0.5,
                       delay: OverlayConstants.transitionDuration * 0.25,
                       options: .curveEaseIn,
                       animations: {
            fromVc?.view.alpha = Alpha.none
            self.chromeView.alpha = Alpha.none
        }) { (finished) in
            fromVc?.view.removeFromSuperview()
            transitionContext.completeTransition(true)
            self.chromeView.removeFromSuperview()
        }

        // Adjust scale more slowly
        UIView.animate(withDuration: OverlayConstants.transitionDuration * 3.0,
                       delay: 0,
                       usingSpringWithDamping: OverlayConstants.damping,
                       initialSpringVelocity: OverlayConstants.springVelocity,
                       options: .curveEaseInOut,
                       animations: {
            fromVc?.view.transform = CGAffineTransform(scaleX: OverlayConstants.initialScale, y: OverlayConstants.initialScale)
        }, completion: nil)
    }
}
