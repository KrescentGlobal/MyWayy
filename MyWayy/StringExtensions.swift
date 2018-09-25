//
//  StringExtensions.swift
//  MyWayy
//
//  Created by SpinDance on 12/15/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

extension String {
    func prependUsernameSymbol() -> String {
        return "@\(self)"
    }
}
extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.heavy(11)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}
