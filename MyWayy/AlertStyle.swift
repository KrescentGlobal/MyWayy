//
//  AlertStyle.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/22/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

enum AlertStyle: String {
    case none = "none"
    case tones = "tones"
    case bells = "bells"
    case voice = "voice"
    case voicePlusTones = "voicePlusTones"
}

extension AlertStyle: CustomDebugStringConvertible {
    var debugDescription: String {
        return description
    }

    var description: String {
        switch self {
        case .none:
            return NSLocalizedString("Off", comment: "")
        case .tones:
            return NSLocalizedString("Soothing Tones", comment: "")
        case .bells:
            return NSLocalizedString("Bells", comment: "")
        case .voice:
            return NSLocalizedString("Voice Notifications", comment: "")
        case .voicePlusTones:
            return NSLocalizedString("Voice Notifications + Tones", comment: "")
        }
    }
}
