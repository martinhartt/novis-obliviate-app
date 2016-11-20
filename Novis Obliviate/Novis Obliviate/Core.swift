//
//  Core.swift
//  Novis Obliviate
//
//  Created by Martin Hartt on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//

import Foundation
import AFNetworking
import Zip
import CoreLocation

typealias updateCallback = (Bool) -> Void

class Core: NSObject, CLLocationManagerDelegate {

  static var sharedInstance = Core()
  
    
    var locationManager: CLLocationManager!
    
    
  var microphoneRecorder: MicrophoneRecorder?
  var accelorometerRecorder: Recorder?
  
  var updateCallback: updateCallback? {
    didSet {
      microphoneRecorder?.updateCallback = self.updateCallback
    }
  }
  
  private override init() {
    super.init()
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    
    
    
    microphoneRecorder = MicrophoneRecorder()
    if let outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      accelorometerRecorder = AccelerometerRecorder(identifier: "", frequency: 40, outputDirectory: outputDirectory)
    }
  }
  
  func start() {
    microphoneRecorder?.start()
    accelorometerRecorder?.start()
  }
  
  func stop() {
    guard
      let accelorometerURL = microphoneRecorder?.stop(),
      let microphoneURL = accelorometerRecorder?.stop()
      else { return }
    
    sendData(accelerometorDataURL: accelorometerURL, microphoneDataURL: microphoneURL)
  }
  
  func sendData(accelerometorDataURL: URL, microphoneDataURL: URL) {
    let zipFilePath = try? Zip.quickZipFiles([
      accelerometorDataURL,
      microphoneDataURL
      ], fileName: "archive_\(NSDate().timeIntervalSince1970)")
    
    let manager = AFHTTPSessionManager()
    
    let url = "http://localhost:9000/api/content"
    
    let params = [
      "familyId":"10000",
      "contentBody" : "Some body content for the test application",
      "name" : "the name/title",
      "typeOfContent":"photo"
    ]
    
    
    manager.post(url, parameters: params, constructingBodyWith: { (data: AFMultipartFormData) in
                  let res = try? data.appendPart(withFileURL: zipFilePath!, name: "combinedZip")
      print("was file added properly to the body? \(res)")
    }, success: { operation, responseObject in
      print("Yes thies was a success")
    }, failure: { operation, error in
      print("We got an error here.. \(error.localizedDescription)")
    })
  }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 3456, minor: 57833, identifier: "MyBeacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("count: \(beacons.count)")
        if beacons.count > 0 {
            updateDistance(beacons[0].proximity)
        } else {
            updateDistance(.unknown)
        }
    }
    
    func updateDistance(_ distance: CLProximity) {
        print(distance.rawValue)
        switch distance {
        case .unknown:
            print("unknown")
            
        case .far:
            print("far")
            
        case .near:
            print("near")
            
        case .immediate:
            print("immediate")
        }
    }
  
}
