//
//  EmailAndPhoneNumberEntry.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/19/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation
import UIKit

struct EmailAndPhoneNumberEntry {
    let email: String?
    let phoneNumber: String?

    init(email: String?, phoneNumber: String?) {
        self.email = email?.trimmingCharacters(in: CharacterSet.whitespaces)
        self.phoneNumber = phoneNumber?.trimmingCharacters(in: CharacterSet.whitespaces)
    }

    var hasAtLeastOneEntry: Bool {
        return hasEmailEntry || hasPhoneNumberEntry
    }

    var hasEmailEntry: Bool {
        return !(email?.isEmpty ?? true)
    }

    var hasPhoneNumberEntry: Bool {
        return !(phoneNumber?.isEmpty ?? true)
    }

    var emailIsValid: Bool {
        guard let theEmail = email else { return false }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: theEmail)
    }

    var phoneNumberIsValid: Bool {
        guard let thePhoneNumber = phoneNumber else { return false }
        let phoneRegex = "^\\+[0-9]{11}$"
//        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: thePhoneNumber)
        return true;
    }
}
