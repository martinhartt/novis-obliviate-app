//
//  CMAccelerometerData+jsonDictionary.swift
//  Novis Obliviate
//
//  Created by Thomas Morrell on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//

import CoreMotion

extension CMAccelerometerData {
    
    var jsonDictionary: [String: Any] {
        
        return ["timestamp": self.timestamp as NSNumber,
                "x": self.acceleration.x as NSNumber,
                "y": self.acceleration.y as NSNumber,
                "z": self.acceleration.z as NSNumber]
    }
}
