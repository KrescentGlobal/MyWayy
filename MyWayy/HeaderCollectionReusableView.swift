//
//  HeaderCollectionReusableView.swift
//  MyWayy
//
//  Created by KITLABS-M-003 on 13/09/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    func setupSearchBar(){
        let searchTextField:UITextField = searchBar.subviews[0].subviews.last as! UITextField
        searchTextField.layer.cornerRadius = 15
        searchTextField.textAlignment = NSTextAlignment.left
       // let image:UIImage = UIImage(named: "uiuiui")?
       // let imageView:UIImageView = UIImageView.init(image: image)
        let view_ = UIView.init()
        view_.backgroundColor = UIColor.clear
        searchTextField.leftView = nil
        searchTextField.placeholder = "search activities"
        searchTextField.placeHolderColor = UIColor.with(Rgb(r: 156, g: 171, b: 186))
        searchTextField.font = UIFont.medium(14)
        searchTextField.rightView = view_
        searchTextField.rightViewMode = UITextFieldViewMode.always
    }
}
