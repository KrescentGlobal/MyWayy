//
//  TabySegmentedControl.swift
//  UISegmentedControlAsTabbarDemo
//
//  Created by Ahmed Abdurrahman on 9/16/15.
//  Copyright © 2015 A. Abdurrahman. All rights reserved.
//

import UIKit

class TabySegmentedControl: UISegmentedControl {
   
    func initUI(){
        setupBackground()
        setupFonts()
    }
    func initWithoutDivider(){
        setupFonts()
    }
    
    func setupBackground(){
        let backgroundImage = UIImage(named: "segmented_unselected_bg")
        let dividerImage = UIImage(named: "segmented_separator_bg")
        let backgroundImageSelected = UIImage(named: "segmented_selected_bg")
        
        self.setBackgroundImage(backgroundImage, for: UIControlState(), barMetrics: .default)
        self.setBackgroundImage(backgroundImageSelected, for: .highlighted, barMetrics: .default)
        self.setBackgroundImage(backgroundImageSelected, for: .selected, barMetrics: .default)
        
        self.setDividerImage(dividerImage, forLeftSegmentState: UIControlState(), rightSegmentState: .selected, barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: .selected, rightSegmentState: UIControlState(), barMetrics: .default)
        self.setDividerImage(dividerImage, forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
    }
    func setupFonts(){
        let font            = UIFont.medium(14)
        let unselectedFont  = UIFont.book(14)
        let selectedTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.lightishBlueFullAlpha,
            NSAttributedStringKey.font: font
        ]
        
        let unSelectedTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.lightishBlueHalfAlpha,
            NSAttributedStringKey.font: unselectedFont
        ]
        self.setTitleTextAttributes(unSelectedTextAttributes, for: UIControlState())
        self.setTitleTextAttributes(selectedTextAttributes, for: .highlighted)
        self.setTitleTextAttributes(selectedTextAttributes, for: .selected)
    }
    
}
