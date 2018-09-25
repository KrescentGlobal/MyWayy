//
//  SearchProfileTableViewCell.swift
//  MyWayy
//
//  Created by SpinDance on 12/4/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class SearchProfileTableViewCell: UITableViewCell {
    static let reuseId = "SearchProfileTableCellView"

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var profileName: UILabel!

    func setup(_ profile: Profile) {
        profileUsername.text = profile.username
        profileUsername.font = UIFont.heavy(24)
        profileUsername.textColor = UIColor.lightishBlueFullAlpha
        profileName.text = profile.name
        profileName.font = UIFont.heavy(12)
        profileName.textColor = UIColor.with(Rgb(r: 103, g: 124, b: 153))

        MyWayyService.shared.getProfileImage(profile, { (success, image, error) in
            self.profileImage.image = nil // necessary to prevent leaving an old image in place
            if image != nil {
                self.profileImage.image = image
                self.profileImage.layer.masksToBounds = false
                self.profileImage.layer.cornerRadius = self.profileImage.frame.height / 2
                self.profileImage.clipsToBounds = true
            }
        })
    }
}
