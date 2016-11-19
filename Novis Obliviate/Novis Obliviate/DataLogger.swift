//
//  DataLogger.swift
//  Novis Obliviate
//
//  Created by Thomas Morrell on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//

import Foundation
import UIKit

class FileHandleError: Error {
    
}

class DataLogger {

    // MARK: Constants
    let directory: URL
    let logName: String
    let formatter: LogFormatter
    
    // MARK: Properties
    var queue: DispatchQueue?
    var currentFileHandle: FileHandle?
    var fileProtection: FileProtectionType?
    
    init?(directory: URL, logName: String, formatter: LogFormatter) {
        
        print("Initialising logger - \(directory.path)")
        if !FileManager.default.fileExists(atPath: directory.path) {
            return nil
        }
        
        if logName.characters.count <= 0 {
            return nil
        }
        
        queue = DispatchQueue(label: "novisObliterate.logger")
        
        self.directory = directory
        self.logName = logName
        self.formatter = formatter
    }
    
    func append(data: [String: Any]) -> Error? {
        
        guard let _ = createFileHandle() else {
            
            return FileHandleError()
        }
        
        queue?.sync {
            formatter.append(object: data, fileHandle: currentFileHandle)
        }
        
        return .none
    }
    
    func finishLogging() {
        
        currentFileHandle?.synchronizeFile()
        currentFileHandle?.closeFile()
    }
    
    func createFileHandle() -> FileHandle? {
        
        guard let fileProtection = fileProtection else { return .none }
        
        if let _ = currentFileHandle {
            return currentFileHandle
        }
        
        let fileManager = FileManager.default
        let logUrl = logFileURL
        let filePath = logFileURL.path
        
        let fileHandle: FileHandle
        if !fileManager.fileExists(atPath: filePath) {
            
            let success = fileManager.createFile(atPath: filePath, contents: .none, attributes: .none)
            if !success {
                return .none
            }
            
            do {
                fileHandle = try FileHandle(forWritingTo: logUrl)
                try fileManager.setAttributes([FileAttributeKey.protectionKey: fileProtection], ofItemAtPath: filePath)
            } catch {
                try? fileManager.removeItem(at: logUrl)
                return .none
            }
        } else {
            
            do {
                fileHandle = try FileHandle(forWritingTo: logUrl)
            } catch {
                
                return .none
            }
        }
        
        currentFileHandle = fileHandle
        return fileHandle
    }
    
    var logFileURL: URL {
        
        return directory.appendingPathComponent(logName)
    }
}
