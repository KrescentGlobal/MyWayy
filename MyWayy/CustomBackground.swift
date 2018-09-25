//
//  CustomBackground.swift
//  MyWayy
//
//  Created by KITLABS-M-003 on 22/08/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit

class CustomBackground: UIView {

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.clear
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            backgroundColor = UIColor.clear
        }
        
    override func draw(_ rect: CGRect) {
            let size = self.bounds.size
            let h = size.height * 0.85      // adjust the multiplier to taste
            
            // calculate the 5 points of the pentagon
            let p0 = self.bounds.origin
        
            let p1 = CGPoint(x:p0.x, y:p0.y + (size.height - h))
            let p2 = CGPoint(x:p1.x + size.width, y:p0.y)
            let p3 = CGPoint(x:p2.x, y:p2.y+size.height)
            let p4 = CGPoint(x:size.width/2, y:size.height)
            let p5 = CGPoint(x:p0.x, y:p0.y+size.height)
            
            // create the path
            let path = UIBezierPath()
                path.move(to: p1)
                path.addLine(to: p2)
                path.addLine(to: p3)
                path.addLine(to: p4)
                path.addLine(to: p5)
                path.close()
            
            // fill the path
        UIColor.veryLightBlueTwo.set()
            path.fill()
        }
}
