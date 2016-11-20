//
//  LogFormatter.swift
//  Novis Obliviate
//
//  Created by Thomas Morrell on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//

import UIKit

class LogFormatter {

    let emptyLogString = "{\"items\":[]}"
    let separatorString = ","
    let footerLogString = "]}"
    
    var emptyLogStringLength: UInt64 = 0
    var footerLogStringLength: UInt64 = 0
    
    init() {
        emptyLogStringLength = UInt64(emptyLogString.data(using: .utf8)!.count)
        footerLogStringLength = UInt64(footerLogString.data(using: .utf8)!.count)
    }
    
    func append(object: [String: Any], fileHandle: FileHandle?) {
        
        guard let fileHandle = fileHandle else { return }
        
        var offset = fileHandle.seekToEndOfFile()
        
        if offset == 0 {
            
            if let data = emptyLogString.data(using: .utf8) {
                fileHandle.write(data)
                offset = fileHandle.seekToEndOfFile()
            }
        }
        
        fileHandle.seek(toFileOffset: offset - footerLogStringLength)

        if offset > emptyLogStringLength {
            
            if let data = separatorString.data(using: .utf8) {
                fileHandle.write(data)
            }
        }
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            fileHandle.write(data)
        } catch {
            print("Failed to generate JSON")
        }
        
        if let data = footerLogString.data(using: .utf8) {
            fileHandle.write(data)
            offset = fileHandle.seekToEndOfFile()
        }
        
    }
}
