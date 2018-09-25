//
//  SearchNextCollectionViewCell.swift
//  MyWayy
//
//  Created by SpinDance on 12/5/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit

class SearchNextCollectionViewCell: UICollectionViewCell {
    static let reuseId = "SearchNextCollectionViewCell"

    @IBOutlet weak var nextButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        let nextTitle = NSLocalizedString("searchNextCollectionViewCell.nextButton.title", comment: "view more results")
        nextButton.setTitle(nextTitle, for: .normal)
    }
}
