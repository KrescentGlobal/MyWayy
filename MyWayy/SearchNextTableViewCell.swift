//
//  SearchNextTableViewCell.swift
//  MyWayy
//
//  Created by SpinDance on 11/28/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class SearchNextTableViewCell: UITableViewCell {
    static let reuseId = "SearchNextTableViewCell"

    @IBOutlet weak var nextButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.heavy(14),
                                                        NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.lightishBlueHalfAlpha,
                                                        NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        let nextTitle = NSMutableAttributedString(string: NSLocalizedString("searchNextTableViewCell.nextButton.title", comment: "view more results"),
                                                        attributes: attributes)
        
        nextButton.setAttributedTitle(nextTitle, for: .normal)
    }
}
