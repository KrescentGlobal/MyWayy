//
//  PagedScrollViewManager.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/29/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

protocol PagedScrollViewManagerDelegate: class {
    func numberOfPages(for manager: PagedScrollViewManager) -> Int
    func manager(_ manager: PagedScrollViewManager, contentViewForPageAt index: Int) -> UIView
    func manager(_ manager: PagedScrollViewManager, scrolledToPageAt index: Int, with pageContentView: UIView)
}

import UIKit

class PagedScrollViewManager: NSObject {

    // MARK: Public Properties

    fileprivate(set) var currentPage: Int = 0

    /// When true, any attempts to view/scroll to pages to the left will be "undone"
    var scrollLeftOnly = false

    // MARK: Private Properties

    fileprivate let scrollView: UIScrollView
    fileprivate weak var delegate: PagedScrollViewManagerDelegate?

    fileprivate var pages = [PageContainerView?]()
    fileprivate var numPages: Int { return delegate?.numberOfPages(for: self) ?? 0 }

    // MARK: Public Methods

    init(scrollView: UIScrollView, delegate: PagedScrollViewManagerDelegate) {
        self.scrollView = scrollView
        self.delegate = delegate
        super.init()
        PagedScrollViewManager.configure(scrollView)
        self.scrollView.delegate = self
    }

    func initialize() {
        for page in pages where page != nil {
            page?.removeFromSuperview()
        }

        /// View controllers are created lazily, in the meantime, load the array
        /// with placeholders which will be replaced on demand.
        pages = [PageContainerView?](repeating: nil, count: numPages)

        adjustScrollViewContentSize()

        // Go to the appropriate page (but with no animation).
        gotoPage(page: currentPage, animated: false)

        scalePages()
    }

    func gotoPage(page: Int, animated: Bool) {
        loadCurrentPages(page: page)

        // Update the scroll view scroll position to the appropriate page.
        var bounds = scrollView.bounds
        bounds.origin.x = bounds.width * CGFloat(page)
        bounds.origin.y = 0
        scrollView.scrollRectToVisible(bounds, animated: animated)
    }

    func pageContentView(at index: Int) -> UIView? {
        guard (index >= 0) && (index < pages.count) else {
            logError()
            return nil
        }
        return pages[index]?.pageContentView
    }

    // MARK: Private Methods

    /// Readjust the scroll view's content size in case the layout has changed.
     func adjustScrollViewContentSize() {
        scrollView.contentSize =
            CGSize(width: scrollView.frame.width * CGFloat(numPages),
                   height: scrollView.frame.height)

        for (index, page) in pages.enumerated() { page?.frame = frameForPage(index) }
    }

    // MARK: - Page Loading and Scaling

    fileprivate func loadPage(_ page: Int) {
        guard page < numPages && page >= 0 else { return }

        if pages[page] == nil {
            if let contentView = delegate?.manager(self, contentViewForPageAt: page) {
                let pageContainer = PageContainerView(frame: frameForPage(page))
                pageContainer.delegate = self
                scrollView.addSubview(pageContainer)
                pageContainer.add(pageContentView: contentView)
                pages[page] = pageContainer
            }
        }
    }

    fileprivate func frameForPage(_ page: Int) -> CGRect {
        // Same size as scrollView, but offset the frame's X origin to its correct page offset.
        var frame = scrollView.frame
        frame.origin.x = frame.width * CGFloat(page)
        frame.origin.y = 0
        return frame
    }

    fileprivate func loadCurrentPages(page: Int) {
        // Don't load if we are at the beginning or end of the list of pages.
        guard (page >= 0 && page < numPages) else { return }

        // Remove offscreen pages.
        for (index, page) in pages.enumerated() {
            if shouldLoadPage(at: index) {
                if page == nil {
                    logDebug("Loading page \(index)")
                    loadPage(index)
                }
            } else {
                if let _ = page {
                    logDebug("Unloading page \(index)")
                }
                page?.removeFromSuperview()
                pages[index] = nil
            }
        }
    }

    fileprivate func shouldLoadPage(at index: Int) -> Bool {
        // Keep two pages either side of the current page loaded so that the
        // loading always occurs when the page is off-screen.
        let extraPages: Int = 2
        let firstPage = currentPage - extraPages
        let lastPage = currentPage + extraPages
        return (index >= firstPage) && (index <= lastPage)
    }

    fileprivate func scalePages() {
        pages.forEach {
            guard let page = $0 else { return }
            // Indicate the distance in points from this page to left side of the
            // scrollview. THen let the pages scale themselves.
            page.pointsToXOrigin = scrollView.contentOffset.x - page.frame.origin.x
        }
    }

    private static func configure(_ scrollView: UIScrollView) {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = true
        scrollView.bouncesZoom = true
        scrollView.isDirectionalLockEnabled = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false

        // Not sure about these
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true
    }
}

// MARK: - UIScrollViewDelegate

extension PagedScrollViewManager: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Scale pages whenever the scrollView offset changes
        scalePages()
    }

    /// Handles programmatic scrolling
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }

    /// Handles user-swipe scrolling
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Switch the indicator when more than 50% of the previous/next page is visible.
        let pageWidth = scrollView.frame.width
        let page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1

        guard !scrollLeftOnly || (Int(page) > currentPage) else {
            gotoPage(page: currentPage, animated: true)
            return
        }

        currentPage = Int(page)
        loadCurrentPages(page: currentPage)
        guard let view = pages[currentPage]!.pageContentView else {
            logError()
            return
        }
        delegate?.manager(self, scrolledToPageAt: currentPage, with: view)
    }
}

// MARK: - PageContainerViewDelegate

extension PagedScrollViewManager: PageContainerViewDelegate {
    func pageContainerViewNeedsLayout(_ pageContainerView: PageContainerView) {
        guard let index = pages.index(where: { (page) -> Bool in
            page == pageContainerView
        }) else {
            logError("Could not determine index of page!")
            return
        }
        pageContainerView.frame = frameForPage(index)
    }
}
