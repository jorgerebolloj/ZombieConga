//
//  MusicUtils.swift
//  ZombiConga
//
//  Created by Jorge Rebollo J on 25/07/16.
//  Copyright © 2016 RGStudio. All rights reserved.
//

import Foundation
import AVFoundation

var backgroundAudioPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let urlSound = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
    if (urlSound == nil) {
        return
    }
    
    do {
        backgroundAudioPlayer = try AVAudioPlayer(contentsOfURL: urlSound!)
        if backgroundAudioPlayer == nil {
            return
        }
        
        backgroundAudioPlayer.numberOfLoops = -1
        backgroundAudioPlayer.prepareToPlay()
        backgroundAudioPlayer.play()
    } catch {
        print("ERROR")
    }
}
