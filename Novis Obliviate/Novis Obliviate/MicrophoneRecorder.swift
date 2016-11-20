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
  var soundLevelHistory: [Double] = []
  var peakValue: Float = -200.0
  var lowestValue: Float = 0.0
  var averageValue: Float = 0.0
  var midValue: Float = 0.0
  var threshold: Double = -400
  var soundFileURL: URL?
  var timer: Timer?
  var updateCallback: updateCallback?
  
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
    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MicrophoneRecorder.updateLevels), userInfo: nil, repeats: true)
  }
  
  var averageAudio = 0.0
  
  func updateLevels() {
    guard let audioRecorder = audioRecorder else { return }
    
    audioRecorder.updateMeters()
    
    let avrg = Double(audioRecorder.peakPower(forChannel: 0))
    let soundLevel: Double = pow(10.0, (0.05 * avrg))
    
    
    averageAudio = soundLevelHistory.reduce(0.0, +) / Double(soundLevelHistory.count)
    
    let prev = isWaterRunning
    isWaterRunning = soundLevel > min(0.2, (averageAudio + 0.02) * 1.5)
    
    if prev != isWaterRunning {
      updateCallback?(isWaterRunning)
    }
    
    print("\(soundLevel) \(averageAudio) \(isWaterRunning)")
    
    if !isWaterRunning {
      soundLevelHistory.append(soundLevel)
    }
    
    
  }
  
  
  func stop() -> URL? {
    audioRecorder?.stop()
    
    timer?.invalidate()
    timer = nil
    
    return soundFileURL
  }
  
}
