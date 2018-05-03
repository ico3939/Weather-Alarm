//
//  SoundManager.swift
//  Weather Alarm
//
//  Created by Student on 5/2/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import AVFoundation

class SoundManager: NSObject {
    
    // MARK: ivars
    // -----------
    var player: AVAudioPlayer?
    
    
    // MARK: Helper Functions
    // ----------------------
    func playAlarm(soundFileName: String) {
        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            if self.player != nil {
                
                // stop the current player if it is playing
                if (self.player?.isPlaying)! {
                    self.player?.stop()
                }
                
                self.player?.prepareToPlay()
                self.player?.play()
            }
            
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopAlarm() {
        
        do {
            
            try AVAudioSession.sharedInstance().setActive(false)
            
            if self.player != nil {
                
                if (self.player?.isPlaying)! {
                    
                    self.player?.stop()
                }
            }
            
        }
        catch let error{
            print(error.localizedDescription)
        }
        
        
    }

}
