//
//  AACarousel.swift
//  AACarousel
//
//  Created by Alan on 2017/6/11.
//  Copyright © 2017年 Alan. All rights reserved.
//

import UIKit

public protocol AACarouselDelegate {
   func didSelectCarouselView(_ view:AACarousel, _ index:Int)
   func callBackFirstDisplayView(_ imageView:UIImageView, _ url:[String], _ index:Int)
   
}

public class AACarousel: UIView,UIScrollViewDelegate {
    
    public var delegate:AACarouselDelegate?
    public var images = [UIImage]()
    public enum direction: Int {
        case left = -1, none, right
    }
    public enum pageControlPosition:Int {
        case top = 0, center = 1, bottom = 2, topLeft = 3, bottomLeft = 4, topRight = 5, bottomRight = 6
    }
    public enum displayModel:Int {
        case full = 0, halfFull = 1
    }
    //MARK:- private property
    
 
    @IBOutlet weak var scrollView: UIScrollView!
    private var layerView:UIView!
   
    @IBOutlet weak var nxtButton: UIButton!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    private var beforeImageView:UIImageView!
    private var currentImageView:UIImageView!
    private var afterImageView:UIImageView!
    public var currentIndex:NSInteger!
    private var describedString = [String]()
    private var descriptionString = [String]()
    private var timer:Timer?
    private var defaultImg:String?
    private var timerInterval:Double?
    private var indicatorPosition:pageControlPosition = pageControlPosition.bottom
    private var carouselMode:displayModel = displayModel.full
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initWithScrollView()
        initWithImageView()
        initWithLayerView()
        initWithGestureRecognizer()
        setNeedsDisplay()
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        setScrollViewFrame()
        setImageViewFrame()
        setLayerViewFrame()
    }
    
    //MARK:- Interface Builder(Xib,StoryBoard)
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        initWithScrollView()
        initWithImageView()
        initWithLayerView()
        initWithGestureRecognizer()
        setNeedsDisplay()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK:- initialize method
    fileprivate func initWithScrollView() {
        
       
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        
    }
    
    fileprivate func initWithLayerView() {
        
        layerView = UIView()
        layerView.backgroundColor = UIColor.black
        layerView.alpha = 0.6
        scrollView.addSubview(layerView)
    }
    
    
    
    
   
    
    fileprivate func initWithImageView() {
        
        beforeImageView = UIImageView()
        currentImageView = UIImageView()
        afterImageView = UIImageView()
        beforeImageView.contentMode = UIViewContentMode.scaleAspectFit
        currentImageView.contentMode = UIViewContentMode.scaleAspectFit
        afterImageView.contentMode = UIViewContentMode.scaleAspectFit
        beforeImageView.clipsToBounds = true
        currentImageView.clipsToBounds = true
        afterImageView.clipsToBounds = true
        scrollView.addSubview(beforeImageView)
        scrollView.addSubview(currentImageView)
        scrollView.addSubview(afterImageView)
        
    }
    
    fileprivate func initWithGestureRecognizer() {
        
        let singleFinger = UITapGestureRecognizer(target: self, action: #selector(didSelectImageView(_:)))
        
        addGestureRecognizer(singleFinger)
    }
   
    fileprivate func initWithData(_ paths:[String],_ describedTitle:[String], descriptionArray : [String]) {
        
        currentIndex = 0
        images.removeAll()
        images.reserveCapacity(paths.count)
     
        //default image
        for _ in 0..<paths.count {
            images.append(UIImage(named: "walkthrough0")!)
        }
        
        //get all image
        for i in 0..<paths.count {
           images[i] = UIImage(named: paths[i]) ?? UIImage()
        }
        
        //get all describeString
        var copyDescribedTitle:[String] = describedTitle
        if describedTitle.count < paths.count {
            let count = paths.count - describedTitle.count
            for _ in 0..<count {
                copyDescribedTitle.append("")
            }
        }
        describedString = copyDescribedTitle
        
        // get all descriptions
        
        var copyDescriptionTitle:[String] = descriptionArray
        if descriptionArray.count < paths.count {
            let count = paths.count - descriptionArray.count
            for _ in 0..<count {
                copyDescriptionTitle.append("")
            }
        }
        descriptionString = copyDescriptionTitle
    }
    
    
    //MARK:- frame method
    fileprivate func setScrollViewFrame() {
        
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentSize = CGSize.init(width: frame.size.width * 5, height:0)
        scrollView.contentOffset = CGPoint.init(x: frame.size.width * 2, y: 0)
        
    }
    
    fileprivate func setLayerViewFrame() {
        
        layerView.frame = CGRect.init(x: 0 , y: scrollView.frame.size.height - 80, width: scrollView.frame.size.width * 5, height: 80)
        layerView.isUserInteractionEnabled = false
    }
    
    fileprivate func setImageViewFrame() {
        
        switch carouselMode {
        case .full:
            beforeImageView.frame = CGRect.init(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            currentImageView.frame = CGRect.init(x: scrollView.frame.size.width * 2, y: 0, width: scrollView.frame.size.width , height: scrollView.frame.size.height)
            afterImageView.frame = CGRect.init(x: scrollView.frame.size.width * 3, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            break
        case .halfFull:
            handleHalfFullImageViewFrame(false)
            beforeImageView.alpha = 0.6
            afterImageView.alpha = 0.6
            break
        }
    }
    
    
    
    //MARK:- set subviews layout method
    public func setCarouselLayout(displayStyle:Int, pageIndicatorPositon:Int, pageIndicatorColor:UIColor?, describedTitleColor:UIColor?, layerColor:UIColor?) {
        
        carouselMode = displayModel.init(rawValue: displayStyle) ?? .full
        indicatorPosition = pageControlPosition.init(rawValue: pageIndicatorPositon) ?? .bottom
        
        layerView.backgroundColor = layerColor ?? .clear
        setNeedsLayout()
    }
    
    //MARK:- set subviews show method
    public func setCarouselOpaque(layer:Bool, describedTitle:Bool, pageIndicator:Bool) {
    
        layerView.isHidden = layer
        titleLabel.isHidden = describedTitle
        descriptionLabel.isHidden = describedTitle
        pageController.isHidden = pageIndicator
    }
    
   
    //MARK:- set data method
    public func setCarouselData(paths:[String],describedTitle:[String], descriptionArray : [String], isAutoScroll:Bool,timer:Double?,defaultImage:String?) {
        
        if paths.count == 0 {
            return
        }
        timerInterval = timer
        defaultImg = defaultImage
        initWithData(paths,describedTitle,descriptionArray: descriptionArray)
        setImage(paths, currentIndex)
        setLabel(describedTitle, currentIndex)
        setDescription(descriptionArray, currentIndex)
        setScrollEnabled(paths, isAutoScroll)
    }
    
    //MARK:- set scroll method
    fileprivate func setScrollEnabled(_ url:[String],_ isAutoScroll:Bool) {
        
        stopAutoScroll()
        //setting auto scroll & more than one
        if isAutoScroll && url.count > 1 {
            scrollView.isScrollEnabled = true
            startAutoScroll()
        } else if url.count == 1 {
            scrollView.isScrollEnabled = false
        }
    }
    
    //MARK:- set first display view
    fileprivate func setImage(_ imageUrl:[String], _ curIndex:NSInteger) {
        
        if imageUrl.count == 0 {
            return
        }
        
        var beforeIndex = curIndex - 1
        let currentIndex = curIndex
        var afterIndex = curIndex + 1
        if beforeIndex < 0 {
            beforeIndex = imageUrl.count - 1
        }
        if afterIndex > imageUrl.count - 1 {
            afterIndex = 0
        }
        
        handleFirstImageView(currentImageView, imageUrl, curIndex)
        //more than one
        if imageUrl.count > 1 {
            handleFirstImageView(beforeImageView, imageUrl, beforeIndex)
            handleFirstImageView(afterImageView, imageUrl, afterIndex)
        }
        pageController.numberOfPages = imageUrl.count
        pageController.currentPage = currentIndex
        layoutSubviews()
        
    }
    
    
    fileprivate func handleFirstImageView(_ imageView:UIImageView,_ imageUrl:[String], _ curIndex:NSInteger) {
        
        delegate?.callBackFirstDisplayView(imageView, imageUrl, curIndex)
    }
    
    fileprivate func setLabel(_ describedTitle:[String], _ curIndex:NSInteger) {
        
        if describedTitle.count == 0 {
            return
        }
        
        titleLabel.text = describedTitle[curIndex]
    }
    
    fileprivate func setDescription(_ descriptionArray:[String], _ curIndex:NSInteger) {
        
        if descriptionArray.count == 0 {
            return
        }
        
        descriptionLabel.text = descriptionArray[curIndex]
    }
    
    //MARK:- change display view
    fileprivate func scrollToImageView(_ scrollDirect:direction) {
        
        if images.count == 0  {
            return
        }
        
        switch scrollDirect {
        case .none:
            
            break
        //right direct
        case .right:
           
          
                beforeImageView.image = currentImageView.image
                currentImageView.image = images[currentIndex]
                
                if currentIndex + 1 > images.count - 1 {
                    afterImageView.image = images[0]
                } else {
                    afterImageView.image = images[currentIndex + 1]
                }
           
            break
        //left direct
        case .left:
            //change ImageView
            
            
                afterImageView.image = currentImageView.image
                currentImageView.image =  images[currentIndex]
                
                if currentIndex - 1 < 0 {
                    beforeImageView.image = images[images.count - 1]
                }else {
                    beforeImageView.image = images[currentIndex - 1]
                }
               
           
            break
        }
        titleLabel.text         = describedString[currentIndex]
        descriptionLabel.text   = descriptionString[currentIndex]
        switch carouselMode {
        case .full:
            break
        case .halfFull:
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
                self.handleHalfFullImageViewFrame(false)
            }, completion: nil)
            
            break
        }
        
        scrollView.contentOffset = CGPoint.init(x: frame.size.width * 2, y: 0)
    }
    
    //MARK:- set auto scroll
    fileprivate func startAutoScroll() {
        
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: timerInterval ?? 5, target: self, selector: #selector(autoScrollToNextImageView), userInfo: nil, repeats: true)
        
    }
    
    fileprivate func stopAutoScroll() {
        
        timer?.invalidate()
        timer = nil
    }
    
    @objc public func autoScrollToNextImageView() {
        if currentIndex != 4 {
            switch carouselMode {
            case .full:
                break
            case .halfFull:
                handleHalfFullImageViewFrame(true)
                break
            }
            scrollView.setContentOffset(CGPoint.init(x: frame.size.width * 3, y: 0), animated: true)
        }
        
        
    }
    
    @objc fileprivate func autoScrollToBeforeImageView() {
       
        switch carouselMode {
        case .full:
            break
        case .halfFull:
            handleHalfFullImageViewFrame(true)
            break
        }
        scrollView.setContentOffset(CGPoint.init(x: frame.size.width * 1, y: 0), animated: true)
        
    }
    
    
    //MARK:- UITapGestureRecognizer
    @objc fileprivate func didSelectImageView(_ sender: UITapGestureRecognizer) {
        
        delegate?.didSelectCarouselView(self, currentIndex)
    }
    
   
    //MARK:- UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if images.count == 0  {
            return
        }
        
        let width = scrollView.frame.width
        let currentPage = ((scrollView.contentOffset.x - width / 2) / width) - 1.5
        let scrollDirect = direction.init(rawValue: Int(currentPage))
        
        switch scrollDirect! {
        case .none:
            break
        default:
            handleIndex(scrollDirect!)
            scrollToImageView(scrollDirect!)
            break
        }
        
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        switch carouselMode {
        case .full:
            break
        case .halfFull:
            handleHalfFullImageViewFrame(true)
            break
        }
        stopAutoScroll()
    }
    
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       
        startAutoScroll()
        
    }
    
    //MARK:- handle scroll imageview frame
    fileprivate func handleHalfFullImageViewFrame(_ isScroll:Bool) {
        
        switch isScroll {
        case true:
            beforeImageView.frame = CGRect.init(x: scrollView.frame.size.width + 30, y: 0, width: scrollView.frame.size.width - 60, height: scrollView.frame.size.height)
            afterImageView.frame = CGRect.init(x: scrollView.frame.size.width * 3 + 30, y: 0, width: scrollView.frame.size.width - 60, height: scrollView.frame.size.height)
            break
        default:
            beforeImageView.frame = CGRect.init(x: scrollView.frame.size.width + 80, y: 20, width: scrollView.frame.size.width - 60, height: scrollView.frame.size.height - 60)
            currentImageView.frame = CGRect.init(x: scrollView.frame.size.width * 2 + 30, y: 0, width: scrollView.frame.size.width - 60, height: scrollView.frame.size.height)
            afterImageView.frame = CGRect.init(x: scrollView.frame.size.width * 3 - 20, y: 20, width: scrollView.frame.size.width - 60, height: scrollView.frame.size.height - 60)
            break
        }
        
       
    }
    
    //MARK:- handle current index
    fileprivate func handleIndex(_ scrollDirect:direction) {
        
        switch scrollDirect {
        case .none:
            break
        case .right:
            currentIndex = currentIndex + 1
            if currentIndex == images.count {
                currentIndex = 0
            }
            break
        case .left:
            currentIndex = currentIndex - 1
            if currentIndex < 0 {
                currentIndex = images.count - 1
            }
            break
        }
        pageController.currentPage = currentIndex
        if currentIndex == 4{
              nxtButton.setTitle("LET'S GET GOING!", for: UIControlState.normal)
              nxtButton.setTitleColor(UIColor.with(Rgb.lightGreen), for: UIControlState.normal)
            
        }else{
            nxtButton.setTitle("NEXT", for: UIControlState.normal)
            nxtButton.setTitleColor(UIColor.with(Rgb.lightishBlue), for: UIControlState.normal)
        }
    }
    
    //MARK:- public control method
    public func startScrollImageView() {
        
        startAutoScroll()
    }
    
    public func stopScrollImageView() {
        
        stopAutoScroll()
    }
}

extension AACarouselDelegate {
    
    func didSelectCarouselView(_ view:AACarousel, _ index:Int) {
    }
    
    func callBackFirstDisplayView(_ imageView:UIImageView, _ url:[String], _ index:Int) {
    }
}
