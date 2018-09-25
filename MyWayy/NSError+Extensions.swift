//
//  NSError+Extensions.swift
//  MyWayy
//
//  Created by Robert Hartman on 1/12/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import Foundation

extension NSError {
    func getAwsErrorMessage() -> String? {
        // Todo: Not clear if "message" or "Message" is the correct key, or if both are.
        let lowercase = userInfo[MyWayyService.AwsErrorMessageKey] as? String
        let uppercase = userInfo["Message"] as? String

        guard lowercase != nil || uppercase != nil else {
            logDebug(String(describing: userInfo))
            return localizedDescription
        }

        // At least one of this is now guaranteed to be non nil
        return lowercase ?? uppercase!
    }
}
