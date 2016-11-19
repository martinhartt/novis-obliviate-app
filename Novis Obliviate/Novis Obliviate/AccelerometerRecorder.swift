//
//  AccelerometerRecorder.swift
//  Novis Obliviate
//
//  Created by Thomas Morrell on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

class AccelerometerRecorder: Recorder {
    
    // MARK: Constants
    let identifier: String
    let frequency: Double
    let outputDirectory: URL
    let mimeType = "application/json"
    let recorderType = "accelerometer"
    
    // MARK: Properties
    var uuid: String
    var isRecording: Bool = false
    var logger: DataLogger?
    var startDate: Date?
    var motionManager: CMMotionManager?
    var operationQueue: OperationQueue?
    
    // MARK: Initialisation
    init(identifier: String, frequency: Double, outputDirectory: URL) {
        self.identifier = identifier
        self.frequency = frequency
        self.outputDirectory = outputDirectory
        self.uuid = UUID().uuidString
    }
    
    // MARK: Recording
    func start() {
        
        if isRecording {
            return
        }
        
        // Start the background task
        let app = UIApplication.shared
        app.beginBackgroundTask(withName: "") {
            self.stop()
        }
        
        // Setup the start date and the motion manager
        startDate = Date()
        motionManager = CMMotionManager()
        operationQueue = OperationQueue()
        
        // Setup the logger
        logger = makeJsonDataLogger()
        
        // Begin recording accelerometer updates
        guard let motionManager = motionManager,
            let operationQueue = operationQueue,
            let logger = logger,
            motionManager.isAccelerometerAvailable else {
            fatalError("Unable to start the recording")
        }
        
        motionManager.accelerometerUpdateInterval = 1.0 / frequency // Set the frequency for updates
        motionManager.stopAccelerometerUpdates() // Cancel previous updates
        
        isRecording = true
        
        motionManager.startAccelerometerUpdates(to: operationQueue, withHandler: { accelerometerData, error in

            if let accelerometerData = accelerometerData {
                let json = accelerometerData.jsonDictionary
                logger.append(data: json)
            }
        })
    }
    
    func stop() -> URL? {
        
        if !isRecording {
            return .none
        }
        
        isRecording = false
        
        stopRecording()
        logger?.finishLogging()
        
        reset()
        
        return .none
    }
    
    func reset() {
        
        uuid = UUID().uuidString
        logger = nil
    }

    private func stopRecording() {
        
        motionManager?.stopAccelerometerUpdates()
        motionManager = .none

    }
    
    // MARK: Data logger creation
    func makeJsonDataLogger() -> DataLogger? {
        
        guard let workingDirectory = recordingDirectoryURL else {
            return .none
        }
        
        do {
            try FileManager().createDirectory(at: workingDirectory, withIntermediateDirectories: true, attributes: .none)
        } catch {
            fatalError("Unable to create the directories for the recording")
        }
        
        let dataLogger = DataLogger(directory: workingDirectory, logName: logName, formatter: LogFormatter())
        dataLogger?.fileProtection = .completeUnlessOpen
        return dataLogger
    }
    
    private var logName: String {
        
        return "\(recorderType)_\(uuid)"
    }
    
    private var recordingDirectoryURL: URL? {
        
        return URL.init(fileURLWithPath: outputDirectory.path.appending("/recorder-\(uuid)"))
    }
}
