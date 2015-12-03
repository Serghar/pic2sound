//
//  SoundEngine.swift
//  pic2sound
//
//  Created by Dylan Sharkey on 11/23/15.
//  Copyright © 2015 Dylan Sharkey. All rights reserved.
//

import UIKit
import AVFoundation

class SoundEngine {
    
    var delegate: ViewController?
    var imageValues: ImageProcessing?
    var audioPlayer = AVAudioPlayer()
    var repeats = 0
    var pitch = 1000
    var speed = 0.0
    var total = 1
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    
    
    //used for the bottom looping bass sounds
    func startBassSoundLoop() {
        
    }
    
    
    //used for high octave melody sounds
    func playOneSound(pitch:Int) {
        if let filePath = NSBundle.mainBundle().pathForResource("SteelDrum_C", ofType: "mp3") {
            let filePathURL = NSURL.fileURLWithPath(filePath)
            audioEngine = AVAudioEngine()
            do { audioFile =  try AVAudioFile(forReading: filePathURL) }
            catch _ { return print("Sound file not found") }
        }
        let pitchPlayer = AVAudioPlayerNode()
        let timePitch = AVAudioUnitTimePitch()
        audioEngine.stop()
        audioEngine.reset()
        
        timePitch.pitch = Float(pitch)
        audioEngine.attachNode(pitchPlayer)
        audioEngine.attachNode(timePitch)
    
        audioEngine.connect(pitchPlayer, to: timePitch, format: audioFile.processingFormat)
        audioEngine.connect(timePitch, to: audioEngine.outputNode, format: audioFile.processingFormat)
        pitchPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        do { try audioEngine.start() }
        catch _ { return print("Audio Engine can't be started") }
    
        pitchPlayer.play()
    }


    //parameter in URLForResource should be file name
    func startSound() {
        
        //set the pitch based on primary color range
        //and speed based on the mean average brightness
        //getSoundPitchAndSpeed()
        
        
        //handle note repetition
        if repeats == 0 {
            pitch = Int(arc4random_uniform(8)) - 4
            pitch = Int(1.0 + (0.0594631 * Double(pitch * 2)) * 1000.0)
            speed = Double(arc4random_uniform(3)) + 1.0
            if speed <= 1.0 {
                repeats = 1
            } else if speed <= 2.0 {
                repeats = 2
            } else {
                repeats = 4
            }
        }
        repeats--

        
        //call the sound after a delay (delay equaling the sound clip length)
        let delay = 0.5 / speed
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), {
            self.playOneSound(self.pitch)
            self.startSound()
        })
    }
    
    //selects appropriate file URL after generating random number
    func getSoundPitchAndSpeed() {
        let primaryArr = imageValues!.primary
        //let meanArr = imageValues!.mean

        let i = 1
        if primaryArr[i] <= 128 && primaryArr[i+1] <= 128 && primaryArr[i+2] <= 128 //Black A
        {pitch = 3}
        else if primaryArr[i] > 128 && primaryArr[i+1] > 128 && primaryArr[i+2] > 128 //White G
        {pitch = -4}
        else if primaryArr[i] > 128 && primaryArr[i+1] > 128 && primaryArr[i+2] <= 128 //Yellow B
        {pitch = 2}
        else if primaryArr[i] <= 128 && primaryArr[i+1] > 128 && primaryArr[i+2] > 128 //Turq E
        {pitch = -2}
        else if primaryArr[i] <= 128 && primaryArr[i+1] <= 128 && primaryArr[i+2] > 128 //Blue F
        {pitch = -3}
        else if primaryArr[i] > 128 && primaryArr[i+1] <= 128 && primaryArr[i+2] > 128 //Magenta C
        {pitch = 1}
        else if primaryArr[i] > 128 && primaryArr[i+1] <= 128 && primaryArr[i+2] <= 128 //Red D
        {pitch = -1}
        
        pitch = Int(1.0 + (0.0594631 * Double(pitch * 2)) * 1000.0)
        
        speed = 1.0
        
    }
}
        