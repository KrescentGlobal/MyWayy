//
//  WalkthroughViewController.swift
//  MyWayy
//  Created by ksglobal on 16/08/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController, AACarouselDelegate {
    
    var pageCount = 0
   
    let arrTitle        = ["Let’s do this together","Plan your day with ease","We’re here to guide you","Discover Wayys","Be Social"]
    let arrDescription  = ["Build new habits with ease by involving friends and followers.","Create Wayys to organize your daily routines.","Stay on track and on time with voice and tone notifications.","Search for friends or your favorite celebrity and try out their routines!","Challenging your friends on MyWayy makes building new habits even more enjoyable."]
    let arrImages       = ["walkthrough0","walkthrough1","walkthrough2","walkthrough3","walkthrough4"]
    
    @IBOutlet var carasaulView: AACarousel!
    @IBOutlet weak var backgroundView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
         setupView()
        // Do any additional setup after loading the view.
       
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func setupView(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.backgroundView.bounds
        let color1 = UIColor(red: 129/255, green: 173/255, blue: 255/255, alpha: 1.0).cgColor as CGColor
        let color2 = UIColor(red: 75/255, green: 116/255, blue: 255/255, alpha: 1.0).cgColor as CGColor
        gradientLayer.colors = [color1, color2]
        gradientLayer.locations = [0.0, 1.00]
        self.backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        carasaulView.delegate = self
        carasaulView.setCarouselData(paths: arrImages,  describedTitle: arrTitle, descriptionArray: arrDescription, isAutoScroll: true, timer: 5.0, defaultImage: "walkthrough0")
        //optional method
        carasaulView.setCarouselOpaque(layer: false, describedTitle: false, pageIndicator: false)
        carasaulView.setCarouselLayout(displayStyle: 0, pageIndicatorPositon:0, pageIndicatorColor: nil, describedTitleColor: nil, layerColor: nil)
        
    }
    
    func didSelectCarouselView(_ view:AACarousel ,_ index:Int) {
        
        
        //startAutoScroll()
        //stopAutoScroll()
    }
    
    //optional method (show first image faster during downloading of all images)
    func callBackFirstDisplayView(_ imageView: UIImageView, _ url: [String], _ index: Int) {
        
        imageView.image = UIImage(named: "walkthrough0")
        
    }
    
    func startAutoScroll() {
        //optional method
        carasaulView.startScrollImageView()
        
    }
    
    func stopAutoScroll() {
        //optional method
        carasaulView.stopScrollImageView()
    }
    @IBAction func nxtAction(_ sender: Any) {
        
            if carasaulView.currentIndex != 4{
                carasaulView.autoScrollToNextImageView()
            }
            else{
               skipAction(self)
            }
    }
    
   
    @IBAction func skipAction(_ sender: Any) {
        // WelcomeViewController
        
        //SessionlessNavigationController
        
        let nextVc = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeNavigation")
        self.present(nextVc!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
