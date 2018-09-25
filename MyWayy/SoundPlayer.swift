//
//  SoundPlayer.swift
//  MyWayy
//
//  Created by Robert Hartman on 11/22/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class SoundPlayer: NSObject {
    static let shared = SoundPlayer()
    fileprivate static let voiceDelayAfterToneSec = 0.0

    fileprivate var playingAudioPlayer: AVAudioPlayer?
    fileprivate lazy var speechSynthesizer = AVSpeechSynthesizer()
    fileprivate var minutesRemainingToAnnounce: UInt?

    override private init() { }

    func play(soundAsset: SoundAsset) {
        guard !speechSynthesizer.isSpeaking && playingAudioPlayer == nil else {
            logDebug("Already playing")
            return
        }

        guard let asset = NSDataAsset(name:soundAsset.assetName) else {
            logError()
            return
        }

        do {
            playingAudioPlayer = try AVAudioPlayer(data: asset.data, fileTypeHint: soundAsset.fileTypeHint)
            playingAudioPlayer?.delegate = self
            playingAudioPlayer?.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func playAlert(with style: AlertStyle, alertIndex: Int, minutesRemaining: UInt) {
        switch style {
        case .none:
            break
        case .bells:
            logError("Bell is not supported")
        case .tones:
            guard let toneAsset = SoundAsset.tone(at: alertIndex) else {
                logError("No tone asset with index \(alertIndex)")
                return
            }
            logDebug("Playing tone '\(toneAsset.assetName)'")
            play(soundAsset: toneAsset)
        case .voice:
            playMinutesRemaining(minutesRemaining)
        case .voicePlusTones:
            minutesRemainingToAnnounce = minutesRemaining
            play(soundAsset: SoundAsset.voiceAlertTone)
        }
    }

    func stop() {
        playingAudioPlayer?.stop()
        speechSynthesizer.stopSpeaking(at: .word)
        playingAudioPlayer?.delegate = nil
        playingAudioPlayer = nil
    }

    fileprivate func playMinutesRemaining(_ minutes: UInt) {
        speechSynthesizer.speak(AVSpeechUtterance(string: ElapsedTimePresenter.timeRemainingString(for: minutes)))
    }
}

extension SoundPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let theMinutes = minutesRemainingToAnnounce

        // Clear these; they are used for maintaining state.
        playingAudioPlayer = nil
        minutesRemainingToAnnounce = nil

        guard let minutes = theMinutes, flag else {  return }

        let time = DispatchTime.now() + SoundPlayer.voiceDelayAfterToneSec
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.playMinutesRemaining(minutes)
        })
    }
}
