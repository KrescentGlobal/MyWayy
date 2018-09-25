//
//  PublicProfileViewController.swift
//  MyWayy
//
//  Created by SpinDance on 12/11/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class PublicProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    static let storyboardId = String(describing: PublicProfileViewController.self)
    var userProfile: Profile? {
        didSet {
            if let templates = userProfile?.routineTemplates {
                userPublicRoutines = templates
            }
        }
    }
    var userPublicRoutines = [RoutineTemplate]()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var profileContentView: UIView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileImageShadowView: UIView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileUsernameLabel: UILabel!
    @IBOutlet weak var profileDurationTotalLabel: UILabel!
    @IBOutlet weak var profileDurationLabel: UILabel!
    
    @IBOutlet weak var profilePublicRoutineCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewStyle()
        setupProfileImage()
        setupProfileInfo()
    }
    
    func setupViewStyle() {
        profileContentView.addRoundedMyWayyShadow(radius: 8)
    }
    
    func setupProfileImage() {
        guard let user = userProfile else {
            return
        }
        MyWayyService.shared.getProfileImage(user, { (success, image, error) in
            if let theImage = image {
                self.profileImage.image = theImage
            }
        })
        self.profileImage.layer.masksToBounds = false
        self.profileImage.layer.cornerRadius = (self.profileImage.frame.height / 2)
        self.profileImage.layer.borderColor = UIColor.paleGrey.cgColor
        self.profileImage.layer.borderWidth = 2
        self.profileImage.clipsToBounds = true
        
        self.profileImageShadowView.layer.masksToBounds = false
        self.profileImageShadowView.layer.shadowColor = UIColor.lightishBlueFullAlpha.cgColor
        self.profileImageShadowView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.profileImageShadowView.layer.shadowRadius = 4.0
        self.profileImageShadowView.layer.shadowOpacity = 0.4
        self.profileImageShadowView.layer.cornerRadius = self.profileImageShadowView.frame.height/2
    }
    
    func setupProfileInfo() {
        profileLabel.text = NSLocalizedString("USER PROFILE", comment: "")
        guard let user = userProfile else {
            return
        }
        
        profileNameLabel.text = user.name
        profileUsernameLabel.text = user.username?.prependUsernameSymbol()
        
        profileDurationTotalLabel.text = "\(user.totalRoutineMinutes!)"
        profileDurationLabel.text = NSLocalizedString("minutes", comment: "")
        
        profilePublicRoutineCollectionView.delegate = self
        profilePublicRoutineCollectionView.dataSource = self
        profilePublicRoutineCollectionView.allowsSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPublicRoutines.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchRoutineCollectionViewCell.reuseId, for: indexPath) as! SearchRoutineCollectionViewCell
        cell.clipsToBounds = false
        cell.setup(userPublicRoutines[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Constants.routineTileSize(from: view.frame)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentPublicRoutineScreen(withRoutineTemplate: userPublicRoutines[indexPath.item])
    }
}
