//
//  SoundAsset.swift
//  MyWayy
//
//  Created by Robert Hartman on 12/2/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation

enum SoundAsset: String {
    case activityComplete = "activity complete"
    case addTime = "add time"
    case pause = "pause"
    case resume = "resume"
    case done = "done"
    case tone0 = "tone 0"
    case tone1 = "tone 1"
    case tone2 = "tone 2"
    case tone3 = "tone 3"
    case tone4 = "tone 4"
    case tone5 = "tone 5"
    case tone6 = "tone 6"
    case tone7 = "tone 7"
    case tone8 = "tone 8"

    var assetName: String { return rawValue }

    var fileTypeHint: String {
        // All the above assets are of this type
        return "com.microsoft.waveform-audio"
    }

    static let voiceAlertTone = SoundAsset.tone0

    static func tone(at index: Int) -> SoundAsset? {
        guard (index >= 0) && (index <= 8) else {
            logError("No tone file exists with index \(index)")
            return nil
        }
        guard let audioFile = SoundAsset(rawValue: "tone \(index)") else {
            logError("Error looking up AudioFile with index \(index)")
            return nil
        }
        return audioFile
    }
}
