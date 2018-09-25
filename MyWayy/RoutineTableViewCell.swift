////
////  RoutineTableViewCell.swift
////  MyWayy
////
////  Created by SpinDance on 10/31/17.
////  Copyright © 2017 MyWayy. All rights reserved.
////
//
//import UIKit
//
class RoutineTableViewCell: UITableViewCell {
//    static let reuseId = String(describing:RoutineTableViewCell.self)
//    static let nibName = reuseId
//    private static let swipeAnimationDuration = 0.25
//    private static let swipeXThreshold: CGFloat = 120
//
//    weak var delegate: RoutineSelectionDelegate?
//    var model = RoutineTableViewCellModel() {
//        didSet {
//            routineName.text = model.routineName
//            durationLabel.text = ElapsedTimePresenter(seconds: model.durationSeconds).stopwatchStringShortWithBiggestUnits
//            routineImageView.image = model.routineImage
//
//            if let name = model.ownerName, !name.isEmpty {
//                creatorName.text = NSLocalizedString("BY @\(name)", comment: "").uppercased()
//            } else {
//                creatorName.text = ""
//            }
//
//            if model.isLoading {
//                spinner.startAnimating()
//                spinner.isHidden = false
//            } else {
//                spinner.stopAnimating()
//                spinner.isHidden = true
//            }
//        }
//    }
//
//    @IBOutlet private weak var startView: UIView!
//    @IBOutlet private weak var startLabel: UILabel!
//    @IBOutlet private weak var routineImageView: ShadedImageView!
//    @IBOutlet private weak var routineName: UILabel!
//    @IBOutlet private weak var creatorName: UILabel!
//    @IBOutlet private weak var durationLabel: UILabel!
//    @IBOutlet private weak var containerView: UIView!
//    @IBOutlet private weak var spinner: UIActivityIndicatorView!
//
//    private lazy var panGesture: UIPanGestureRecognizer = {
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
//        gesture.delegate = self
//        return gesture
//    }()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        containerView.addGestureRecognizer(panGesture)
//        setStyle()
//    }
//
//    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//    private func setStyle() {
//        routineName.set(UIFont.heavy(18), UIColor.white)
//        creatorName.set(UIFont.heavy(10), UIColor.with(Rgb(r: 178, g: 189, b: 204)))
//        durationLabel.set(UIFont.heavy(14), UIColor(white: 1.0, alpha: 0.8))
//
//        startLabel.set(UIFont.heavy(18), .white)
//        startView.addRoundedMyWayyShadow(radius: 8)
//
//        routineImageView.layer.cornerRadius = 5
//        routineImageView.clipsToBounds = true
//
//        containerView.backgroundColor = .clear
//    }
//
//    @objc func panGesture(gesture: UIPanGestureRecognizer) {
//        guard let view = containerView, gesture.view == view else {
//            logError()
//            return
//        }
//        let currentX = view.center.x
//        let referenceX = contentView.center.x
//        let newX = gesture.translation(in: view).x
//        let toTheLeft = currentX <= referenceX && newX <= 0
//        let tooFar = referenceX - currentX > RoutineTableViewCell.swipeXThreshold + 20
//        var farEnough = referenceX - currentX >= RoutineTableViewCell.swipeXThreshold
//
//        gesture.setTranslation(CGPoint(x: 0, y: 0), in: view)
//
//        switch gesture.state {
//        case .began, .changed:
//            guard toTheLeft && !tooFar else {
//                //logDebug("Won't allow right swipe, or too far")
//                return
//            }
//            // Move the view
//            view.center = CGPoint(x: view.center.x + newX, y: view.center.y)
//        case .ended:
//            if !farEnough {
//                resetPan(animated: true)
//            }
//        default:
//            farEnough = false
//            break
//        }
//
//        if farEnough {
//            gesture.cancel()
//            delegate?.userDidActivateRoutine(for: self)
//            resetPan(animated: true)
//        }
//    }
//
//    private func resetPan(animated: Bool) {
//        let block = {
//            self.containerView.center = CGPoint(x: self.contentView.center.x, y: self.containerView.center.y)
//        }
//        guard animated else {
//            block()
//            return
//        }
//
//        // Animate recentering containerView
//        UIView.animate(withDuration: RoutineTableViewCell.swipeAnimationDuration) {
//            block()
//        }
//    }
}


