//
//  ComingRoutineItems.swift
//  MyWayy
//
//  Created by Navpreet Kaur on 8/31/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit

class ComingRoutineItems: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    
    @IBOutlet weak var collectionView: UICollectionView!
    var cellModels = [RoutineTableViewCellModel]()
    var todaysRoutines = [Routine]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        collectionView.addGestureRecognizer(lpgr)
        self.collectionView.register(UINib.init(nibName: "RoutineCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "myCell")
        self.contentView.backgroundColor = UIColor.clear
        
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.collectionView)
        
        if let indexPath = self.collectionView.indexPathForItem(at: p) {
             let indexPathDict:[String: Int] = ["index": indexPath.row]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notifyMeLongPress"), object: nil, userInfo: indexPathDict)
        } else {
            print("couldn't find index path")
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath as IndexPath) as! RoutineCollectionViewCell
        
        cell.model = cellModels[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Display the routine's notifications on the console, for debugging purposes.
        //LocalNotificationHandler.displayPendingNotifications(for: routine)
         let indexPathDict:[String: Int] = ["index": indexPath.row]
        
       
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notifyMe"), object: nil, userInfo: indexPathDict)
        
        
        
        
        CFRunLoopWakeUp(CFRunLoopGetCurrent())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:310, height: 260)
    }

}
extension ComingRoutineItems: RoutineSelectionDelegate {
    func userDidActivateRoutine(for cell: RoutineCollectionViewCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else {
            logError()
            return
        }
        //        presentActiveRoutineScreen(with: todaysRoutines[indexPath.row])
    }
}
