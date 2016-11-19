//
//  File.swift
//  Novis Obliviate
//
//  Created by Martin Kubat on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//

import Foundation

protocol Recorder {
  func start()
  func stop() -> URL
}
