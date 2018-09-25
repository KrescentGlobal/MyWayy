//
//  PageContainerView.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/29/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

private struct PcvConstants {
    ////////////////////////////////////////////////////////////////////////////
    // EDIT THESE TO ADJUST RELATIVE EXPANDED/REDUCED PAGE SIZE

    /// Defines the scaling applied to this view's content when this page is >=
    /// one page away from being the current page. I.e., contentView's scale
    /// will be reduced linearly from a scale of 1.0 to this value as it moves
    /// from being the current page to one page away.
    static let minimumScale: CGFloat = 0.75

    /// A factor used to decrease the expansion factor a bit to allow for a
    /// little gap between the center and adjacent pages.
    private static let expansionScaleReductionFactor: CGFloat = 0.99

    ////////////////////////////////////////////////////////////////////////////
    // DON'T EDIT THESE!

    /// This is the factor by which the width of each page is increased such that
    /// it overflows the containing view's horizontal bounds, when it's the center
    /// page, in order to fill up some of the gap caused by the adjacent views
    /// being scaled down.
    static let expansionScale = (1.0 / expansionScaleDivisor) * expansionScaleReductionFactor

    /// Used to decrease the scaling (width increase) of pages by about half of
    /// the decreased scale ued for pages that are not the center, onscreen page.
    /// This seems to pretty well make it so that the expanded center page's
    /// edges just meet the edges of the adjacent pages.
    private static let expansionScaleDivisor = 1.0 - ((1.0 - minimumScale) / 2)
}

protocol PageContainerViewDelegate: class {
    func pageContainerViewNeedsLayout(_ pageContainerView: PageContainerView)
}

class PageContainerView: UIView {
    weak var delegate: PageContainerViewDelegate?
    var pointsToXOrigin: CGFloat = 0 {
        didSet {
            // When this page is one page away from the containing view's x
            // origin, we want its scale to be set to minimumScale. After that,
            // don't let it get smaller.
            let scaleReduction = abs(pointsToXOrigin) / bounds.width * (1 - PcvConstants.minimumScale)
            scale = max(1 - scaleReduction, PcvConstants.minimumScale)
        }
    }
    private var scale: CGFloat = 0 {
        willSet {
            guard newValue != scale else { return }
            pageContentView?.layer.transform = CATransform3DScale(CATransform3DIdentity, newValue, newValue, 1)
        }
    }
    private(set) var pageContentView: UIView?

    override func layoutSubviews() {
        super.layoutSubviews()
        delegate?.pageContainerViewNeedsLayout(self)
    }

    func add(pageContentView view: UIView) {
        self.pageContentView?.removeFromSuperview()

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        // Setup the child view's constraints to center it and expand its size
        // according to the expansion scale.
        NSLayoutConstraint.activate([
            (view.centerXAnchor.constraint(equalTo: centerXAnchor)),
            (view.centerYAnchor.constraint(equalTo: centerYAnchor)),
            (view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: PcvConstants.expansionScale)),
            (view.heightAnchor.constraint(equalTo: heightAnchor, multiplier: PcvConstants.expansionScale))])

        pageContentView = view
    }
}

