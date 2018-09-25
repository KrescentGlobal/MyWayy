//
//  PopupView.swift
//  MyWayy
//
//  Created by KITLABS-M-003 on 18/09/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation
import AANotifier
class PopupView: AANibView {
     var notifer: AANotifier?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        let formattedString = NSMutableAttributedString()
        formattedString
            .normal("Delete the ")
            .bold("1 selected ")
            .normal("activity?")
         titleLabel.attributedText = formattedString
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabel(notification:)), name: NSNotification.Name(rawValue: "updateLabel"), object: nil)
    }
    @objc func updateLabel(notification : Notification){
    
        if let count_ =  notification.userInfo?["count_"] as? Int{
            print(count_)
            let formattedString = NSMutableAttributedString()
            formattedString
                .normal("Delete the ")
                .bold("\(count_) selected ")
                .normal("activities?")
            titleLabel.attributedText = formattedString
            if count_ == 0{
                notifer?.animateNotifer(false)
            }
        }
       
        
    }
}
