//
//  HomeRoutineItems.swift
//  MyWayy
//
//  Created by KITLABS-M-003 on 31/08/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//{
//didSet {
//    // Reset the cell models
//    cellModels = [RoutineTableViewCellModel]()
//    collectionView.reloadData()
//}
//}

import UIKit

class HomeRoutineItems: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
     var cellModels = [RoutineTableViewCellModel]()
     var todaysRoutines = [Routine]()
    var cellModel = RoutineTableViewCellModel()
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellModel.isLoading = false
        cellModel.routineId = 0
        cellModel.routineImage = UIImage(named: "wayyList1")
        cellModel.routineName = "Any name"
        cellModel.ownerName = "Any name"
        cellModel.durationSeconds = 10
       
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "RoutineCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "myCell")
        self.contentView.backgroundColor = UIColor.clear
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return cellModels.count
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath as IndexPath) as! RoutineCollectionViewCell
        
//              cell.model = cellModels[indexPath.row]
                cell.model = cellModel
                cell.delegate = self
        
        cell.completedView.isHidden = true
        if indexPath.row == 0 {
           cell.completedView.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let routine = todaysRoutines[indexPath.row]
        
        
        
        // Display the routine's notifications on the console, for debugging purposes.
        //LocalNotificationHandler.displayPendingNotifications(for: routine)
        
//        presentPublicRoutineScreen(withRoutine: routine)
        
        
//        CFRunLoopWakeUp(CFRunLoopGetCurrent())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:310, height: 260)
       
    }

}
extension HomeRoutineItems: RoutineSelectionDelegate {
    func userDidActivateRoutine(for cell: RoutineCollectionViewCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else {
            logError()
            return
        }
//        presentActiveRoutineScreen(with: todaysRoutines[indexPath.row])
    }
}
