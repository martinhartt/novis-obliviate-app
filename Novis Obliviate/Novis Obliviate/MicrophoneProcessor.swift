//
//  MicrophoneProcessor.swift
//  Novis Obliviate
//
//  Created by Martin Hartt on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class MicrophoneProcessor: NSObject {
  
  var audioRecorder: AVAudioRecorder?
  var isWaterRunning: Bool = false
  var soundLevelHistory: [Double] = []
  
  override init() {
    super.init()
    
    
    let directories = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
    
    let soundFileURL = directories[0].appendingPathComponent("sound.caf")

    
    let recordSettings =
      [AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
       AVEncoderBitRateKey: 16,
       AVNumberOfChannelsKey: 2,
       AVSampleRateKey: 44100.0] as [String : Any]
    
    let audioSession = AVAudioSession.sharedInstance()
    
    do {
      try audioSession.setCategory(
        AVAudioSessionCategoryPlayAndRecord)
    } catch let error as NSError {
      print("audioSession error: \(error.localizedDescription)")
    }
    
    do {
      self.audioRecorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings as [String : AnyObject])
      audioRecorder?.prepareToRecord()
      audioRecorder?.isMeteringEnabled = true
      
    } catch let error as NSError {
      print("audioSession error: \(error.localizedDescription)")
    }
    
    startRecording()
  }
  
  func startRecording() {
    audioRecorder?.record()
    Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MicrophoneProcessor.updateLevels), userInfo: nil, repeats: true)
    print("Start recording")
  }
  
  func updateLevels() {
    guard let audioRecorder = audioRecorder else { return }
    
    audioRecorder.updateMeters()
    
    let avrg = Double(audioRecorder.averagePower(forChannel: 0))
    let soundLevel: Double = pow(10.0, (0.05 * avrg))

    let difference = soundLevel - (soundLevelHistory.count > 10 ? soundLevelHistory[soundLevelHistory.count - 9] : 0.0)
    
    if (isWaterRunning) {
      
      if avrg < -40 {
        isWaterRunning = false
      }
      
    } else  {
      
      if avrg > -40 {
        isWaterRunning = true
      }
      
      //print("\(difference)")
    }
    
    soundLevelHistory.append(soundLevel)
    
    print("\(isWaterRunning) \(avrg) \(difference)")
  }
  
  
  func stopRecording() {
    audioRecorder?.stop()
  }
  
  
  
}
