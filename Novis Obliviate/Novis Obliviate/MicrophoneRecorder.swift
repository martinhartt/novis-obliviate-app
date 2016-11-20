//
//  MicrophoneProcessor.swift
//  Novis Obliviate
//
//  Created by Martin Hartt on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//

import UIKit
import AVFoundation

class MicrophoneRecorder: NSObject, Recorder {
  
  var audioRecorder: AVAudioRecorder?
  var isWaterRunning: Bool = false
  var soundLevelHistory: [Double] = Array(repeating: 0.0, count: 200)
  var peakValue: Float = -200.0
  var lowestValue: Float = 0.0
  var averageValue: Float = 0.0
  var midValue: Float = 0.0
  var threshold: Double = -400
  var soundFileURL: URL?
  var timer: Timer?
  var updateCallback: updateCallback?
  var frame = 0

  
  
  var wantTurnOn = 0.0
  
  override init() {
    super.init()
    
    let directories = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
    
    soundFileURL = directories[0].appendingPathComponent("sound.caf")

    
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
      self.audioRecorder = try AVAudioRecorder(url: soundFileURL!, settings: recordSettings as [String : AnyObject])
      audioRecorder?.prepareToRecord()
      audioRecorder?.isMeteringEnabled = true
      
    } catch let error as NSError {
      print("audioSession error: \(error.localizedDescription)")
    }
    
  }
  
  func start() {
    audioRecorder?.record()
    timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(MicrophoneRecorder.updateLevels), userInfo: nil, repeats: true)
  }
  
  var averageAudio = 0.0
  
  func updateLevels() {
    guard let audioRecorder = audioRecorder else { return }
    
    audioRecorder.updateMeters()
    
    let avrg = Double(audioRecorder.averagePower(forChannel: 0))
    let soundLevel: Double = pow(10.0, (0.05 * avrg))
    
    
    averageAudio = soundLevelHistory.reduce(0.0, +) / Double(soundLevelHistory.count)
    
    let prev = isWaterRunning
    let localResult = soundLevel > min(0.2, (averageAudio + 0.02) * 1.5) && frame > soundLevelHistory.count
    
    wantTurnOn += localResult ? 2.0 : -0.2
    
    
    let threshold = 5.0
    if wantTurnOn > threshold {
      isWaterRunning = true
      wantTurnOn = 0
    } else if wantTurnOn < -threshold {
      isWaterRunning = false
      wantTurnOn = 0
    }
    
    if prev != isWaterRunning {
      updateCallback?(isWaterRunning)
    }
    
    
    //print("\(soundLevel) \(averageAudio) \(isWaterRunning)")
    
    if !isWaterRunning {
      soundLevelHistory[frame % soundLevelHistory.count] = soundLevel
    }
    frame += 1
    
    
  }
  
  
  func stop() -> URL? {
    audioRecorder?.stop()
    
    timer?.invalidate()
    timer = nil
    
    return soundFileURL
  }
  
}
