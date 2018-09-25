//
//  RoutineCollectionViewCell.swift
//  MyWayy
//
//  Created by KITLABS-M-003 on 31/08/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//
import UIKit

protocol RoutineSelectionDelegate: class {
    func userDidActivateRoutine(for cell: RoutineCollectionViewCell)
}

class RoutineTableViewCellModel {
    var isLoading: Bool = false
    var routineId: Int?
    var routineImage: UIImage? = nil
    var routineName: String? = nil
    var ownerName: String? = nil
    var durationSeconds = 0
}

class RoutineCollectionViewCell: UICollectionViewCell

{
    
    private static let swipeAnimationDuration = 0.25
    private static let swipeXThreshold: CGFloat = 120
    
    weak var delegate: RoutineSelectionDelegate?
    var model = RoutineTableViewCellModel() {
        didSet {
            routineName.text = model.routineName
            durationLabel.text = ElapsedTimePresenter(seconds: model.durationSeconds).stopwatchStringShortWithBiggestUnits
            routineImageView.image = model.routineImage
            
            if model.isLoading {
                spinner.startAnimating()
                spinner.isHidden = false
            } else {
                spinner.stopAnimating()
                spinner.isHidden = true
            }
        }
    }
    
  
    @IBOutlet weak var completedView: UIView!
    @IBOutlet private weak var routineImageView: ShadedImageView!
    @IBOutlet private weak var routineName: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
//    private lazy var panGesture: UIPanGestureRecognizer = {
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
//        gesture.delegate = self
//        return gesture
//    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        containerView.addGestureRecognizer(panGesture)
        setStyle()
    }
    
//    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
    private func setStyle() {
     
        routineImageView.layer.cornerRadius = 5
        routineImageView.clipsToBounds = true
        
    }
    
    @objc func panGesture(gesture: UIPanGestureRecognizer) {
        guard let view = containerView, gesture.view == view else {
            logError()
            return
        }
        let currentX = view.center.x
        let referenceX = contentView.center.x
        let newX = gesture.translation(in: view).x
        let toTheLeft = currentX <= referenceX && newX <= 0
        let tooFar = referenceX - currentX > RoutineCollectionViewCell.swipeXThreshold + 20
        var farEnough = referenceX - currentX >= RoutineCollectionViewCell.swipeXThreshold
        
        gesture.setTranslation(CGPoint(x: 0, y: 0), in: view)
        
        switch gesture.state {
        case .began, .changed:
            guard toTheLeft && !tooFar else {
                //logDebug("Won't allow right swipe, or too far")
                return
            }
            // Move the view
            view.center = CGPoint(x: view.center.x + newX, y: view.center.y)
        case .ended:
            if !farEnough {
                resetPan(animated: true)
            }
        default:
            farEnough = false
            break
        }
        
        if farEnough {
            gesture.cancel()
            delegate?.userDidActivateRoutine(for: self)
            resetPan(animated: true)
        }
    }
    
    private func resetPan(animated: Bool) {
        let block = {
            self.containerView.center = CGPoint(x: self.contentView.center.x, y: self.containerView.center.y)
        }
        guard animated else {
            block()
            return
        }
        
        // Animate recentering containerView
        UIView.animate(withDuration: RoutineCollectionViewCell.swipeAnimationDuration) {
            block()
        }
    }
}
