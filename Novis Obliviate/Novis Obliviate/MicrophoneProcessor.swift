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
      self.audioRecorder = try? AVAudioRecorder(url: soundFileURL, settings: recordSettings as [String : AnyObject])
      audioRecorder?.prepareToRecord()
      audioRecorder?.isMeteringEnabled = true
      
    } catch let error as NSError {
      print("audioSession error: \(error.localizedDescription)")
    }
    
    startRecording()
  }
  
  func startRecording() {
    audioRecorder?.record()
    let timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MicrophoneProcessor.test), userInfo: nil, repeats: true)
    print("Start recording")
  }
  
  func test() {
    print("Hello!")
    
    audioRecorder?.updateMeters()
    print(self.audioRecorder?.averagePower(forChannel: 0))
  }
  
  
  func stopRecording() {
    audioRecorder?.stop()
  }
  
  
  
}
