//
//  SearchRoutineFooterCollectionReusableView.swift
//  MyWayy
//
//  Created by SpinDance on 12/6/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class SearchRoutineFooterCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var viewMoreResultsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.heavy(14),
                                                        NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.lightishBlueHalfAlpha,
                                                        NSAttributedStringKey(rawValue: NSAttributedStringKey.underlineStyle.rawValue): NSUnderlineStyle.styleSingle.rawValue]
        let nextTitle = NSMutableAttributedString(string: NSLocalizedString("searchNextTableViewCell.nextButton.title", comment: "view more results"),
                                                  attributes: attributes)
        
        viewMoreResultsButton.setAttributedTitle(nextTitle, for: .normal)
    }
    
}
