//
//  SelectIconViewController.swift
//  MyWayy
//
//  Created by SpinDance on 11/3/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    var iconImageName: String?
}

class SelectIconViewController: ActivityCreationOverlayViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var tabBar: TabySegmentedControl!
    
    //TODO: There has to be a better way to access imageset names - will suffice for demo
    let iconArray:[String] = ["aerobics", "baby", "beach", "beer", "bike", "book_open", "book", "call", "camera", "car", "cat", "challenge", "challenge2", "chat", "chat2peeps", "clean", "clock", "clothes", "code copy 2", "code", "cook", "design", "dog", "edit", "focus", "food", "gaming", "guitar", "hair", "headphones", "heart", "hike", "house", "idea", "internet", "laundry", "magic", "mail", "map", "microphone", "moon", "movie", "muscle", "mustache", "news", "office", "paint", "people", "personrunning", "phone", "piano", "plant", "rockon", "run copy 4", "run copy 6", "run copy", "run", "runningshoe", "science", "settings", "share_profile", "share", "sled", "sleep", "speak", "strategy", "stretch", "swim", "system", "text", "tool", "water copy", "water", "weight", "yinyang"]
    
    @IBOutlet weak var iconCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        iconCollectionView.delegate = self
        iconCollectionView.dataSource = self
        iconCollectionView.allowsSelection = true
        tabBar.initWithoutDivider()
       
    }
    
    @IBAction func backButtonPress(_ sender: UIButton) {
        activityModel?.iconName = nil
        dismiss(animated: true, completion: nil)
    }
    
   
    
    //Number of views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconArray.count
    }
    
    //Populate views
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconImageCollectionCell", for: indexPath) as! IconCollectionViewCell
        cell.iconImage.image = UIImage(named: iconArray[indexPath.row])
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.cornerRadius = cell.frame.height/2
        cell.iconImage.layer.masksToBounds = true
        if !cell.isSelected {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor
        } else if cell.isSelected {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor.with(Rgb(r: 20, g: 49, b: 127)).withAlphaComponent(0.08).cgColor
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        activityModel?.iconName = iconArray[indexPath.row]
        dismiss(animated: true, completion: nil)
    }
    

}
