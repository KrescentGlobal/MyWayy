//
//  OnboardSecondViewController.swift
//  MyWayy
//
//  Created by KITLABS-M-003 on 23/08/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit

class OnboardSecondViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BusyOverlayOwner {
   
    let overlay = BusyOverlayView.create()
    private let pageController = UIPageControl()
    private var shoulResize = true
    @IBOutlet weak var completeBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var arrTitle = ["Getting Up Earlier","Finding More Me Time","Staying Active","Winning at Home","Getting Outside"]
    var arrImages = ["clock","rockon","muscle","house","movie"]
    var selectedIndex = [Int]()
    var onboardData = Onboard()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupUI()
        // Do any additional setup after loading the view.
    }
   
    
    
    @IBAction func backAc(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Scroll View Delegates
    
    private func showImage(_ show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.pageController.alpha = show ? 1.0 : 0.0
        }
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let navigationTitleFont = UIFont.medium(14)
        let navigationLargeTitleFont = UIFont.medium(24)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont, NSAttributedStringKey.foregroundColor: UIColor.with(Rgb(r: 73, g: 80, b: 87))]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.font: navigationLargeTitleFont, NSAttributedStringKey.foregroundColor: UIColor.with(Rgb(r: 73, g: 80, b: 87))]
        let navBarsize = navigationController!.navigationBar.bounds.size
        let origin = CGPoint(x: navBarsize.width/2-15, y: 20)
        pageController.frame =  CGRect(x: origin.x, y: origin.y, width: 30, height: 30)
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(pageController)
        pageController.numberOfPages = 2
        pageController.currentPage = 1
        pageController.currentPageIndicatorTintColor = UIColor.with(Rgb(r: 75, g: 116, b: 255))
        pageController.pageIndicatorTintColor = UIColor.with(Rgb(r: 144, g: 144, b: 144))
        NSLayoutConstraint.activate([
            pageController.topAnchor.constraint(equalTo: navigationBar.topAnchor,
                                                constant: -10),
            pageController.rightAnchor.constraint(equalTo: navigationBar.centerXAnchor, constant: 0),
            pageController.heightAnchor.constraint(equalToConstant: 30),
            pageController.widthAnchor.constraint(equalTo: pageController.heightAnchor)
            ])
    }
    
   
    func setupCollectionView(){
    
        collectionView.delegate = self
        collectionView.dataSource = self
        completeBtn.backgroundColor = UIColor.lightTeal
        completeBtn.titleLabel?.textColor = UIColor.white.withAlphaComponent(0.5)
        
    }
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrTitle.count ?? 0
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: UICollectionViewCell?
        var imageView: UIImageView?
        var titleLabel : UILabel?
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath)
        imageView = cell?.contentView.viewWithTag(1) as? UIImageView
        titleLabel = cell?.contentView.viewWithTag(2) as? UILabel
        if let imageView = imageView {
            imageView.image = UIImage(named: arrImages[indexPath.row])
            
        }
        if let titleLabel = titleLabel{
            titleLabel.text = arrTitle[indexPath.row]
        }
        if selectedIndex.contains(indexPath.row){
            cell?.contentView.viewWithTag(4)?.isHidden = false
            cell?.contentView.viewWithTag(3)?.borderWidth = 1.5
        }else{
            cell?.contentView.viewWithTag(4)?.isHidden = true
            cell?.contentView.viewWithTag(3)?.borderWidth = 0
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width/2-8, height: self.view.frame.size.width/2)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if selectedIndex.contains(indexPath.row){
            selectedIndex.remove(at: selectedIndex.index(of: indexPath.row)!)
        }else{
            selectedIndex.append(indexPath.row)
        }
        if selectedIndex.count == 0 {
          completeBtn.isEnabled = false
            completeBtn.titleLabel?.textColor = UIColor.white.withAlphaComponent(0.5)
        }
        else{
            completeBtn.isEnabled = true
            completeBtn.titleLabel?.textColor = UIColor.white.withAlphaComponent(1.0)
        }
        collectionView.reloadData()
    }
    
    @IBAction func completeAction(_ sender: Any) {
        
        self.showOverlay()
        for value in selectedIndex{
            onboardData.interest = "\(onboardData.interest), \(arrTitle[value])"
        }
        
       self.loginUser()
       
    }
    
    func createUser(_ user: AWSCognitoIdentityUser){
        
        guard let sharedProfile = MyWayyService.shared.profile else {
            self.hideOverlay()
            return
        }
        
        sharedProfile.name = onboardData.name
        sharedProfile.email = onboardData.email
        sharedProfile.phoneNumber = onboardData.phone
        sharedProfile.description = onboardData.description
        sharedProfile.interest = onboardData.interest
        
            MyWayyService.shared.loadProfile({ (success, error) in
//                MyWayyService.shared.setProfileImage(MyWayyService.shared.profile!, image: self.onboardData.image, { (success, error) in
//                    
//                })
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.login(user)
                }
                self.hideOverlay()
            })
    }
    
    
    private func loginUser() {
        
        MyWayyService.shared.login(username: onboardData.userName, password: onboardData.password, { (user: AWSCognitoIdentityUser, response: AWSCognitoIdentityUserSession?, nserror: NSError?) in
           
            if let error = nserror {
                self.hideOverlay()
                switch error.code {
                case AWSCognitoIdentityProviderErrorType.userNotFound.rawValue:
                    print("error: User does not exist exists")
                case AWSCognitoIdentityProviderErrorType.notAuthorized.rawValue:
                    print("error: Invalid username or password")
                case AWSCognitoIdentityProviderErrorType.userNotConfirmed.rawValue:
                    print("error: User not confirmed")
                default:
                    print("error: \(error)")
                }
            } else {
                print("response: \(String(describing: response))")
                self.dismiss(animated: true, completion: {
                    self.createUser(user)
                })
            }
        })
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
