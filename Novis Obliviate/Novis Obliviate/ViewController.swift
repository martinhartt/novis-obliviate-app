//
//  ViewController.swift
//  Novis Obliviate
//
//  Created by Martin Kubat on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var startRecordingLabel: UILabel!

  @IBOutlet weak var startRecordingButton: UIButton!
  var isRecording = false
  var core = Core.sharedInstance
  
  var brainView: UIImageView!
  var boltViews: [UIImageView] = []
  var boltPositions = [CGPoint]()
  
  
  override func viewDidLoad() {
  super.viewDidLoad()
    setup()
  // Do any additional setup after loading the view, typically from a nib.
    
    core.updateCallback = { isWaterRunning in
      UIView.animate(withDuration: 0.3, animations: {
        
        //self.view.backgroundColor = isWaterRunning ? UIColor.blue : UIColor.white
      })
    
    }
  }
  
  func setup() {
    brainView = UIImageView(image: UIImage(named: "brain")!)
    brainView.contentMode = .center
    brainView.frame = view.bounds
    view.addSubview(brainView)
    
    
    for i in 1...6 {
      let boltView = UIImageView(image: UIImage(named: "bolt\(i)"))
      boltView.contentMode = .center
      
      boltView.frame.origin = CGPoint(x: view.frame.midX, y: view.frame.midY)
      
      view.addSubview(boltView)
      boltViews.append(boltView)
      
      switch i {
      case 1:
        boltView.frame.origin.x -= 100.0
      case 2:
        boltView.frame.origin.x -= 70.0
        boltView.frame.origin.y -= 40.0
      case 3:
        boltView.frame.origin.x -= 40.0
        boltView.frame.origin.y -= 45.0
      case 4:
        boltView.frame.origin.x += 40.0
        boltView.frame.origin.y -= 45.0
      case 5:
        boltView.frame.origin.x += 70.0
        boltView.frame.origin.y -= 30.0
      case 6:
        boltView.frame.origin.x += 100.0
      default:
        break
      }
      boltPositions.append(boltView.frame.origin)
    }
    Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateAnimation), userInfo: nil, repeats: true)
    
  }
  
  func updateAnimation() {
    guard isRecording else { return }
    
    for i in 0...5 {
      let randomX = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * 2
      let randomY = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * 2

      var x = boltPositions[i].x
      x += randomX
      
      var y = boltPositions[i].y
      y += randomY
      
      boltViews[i].frame.origin = CGPoint(x: x, y: y)
      
      let scale = 0.8 + randomX / 4.0
      boltViews[i].transform = CGAffineTransform(scaleX: scale, y: scale)
      
    
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func startRecording(startRecording : UIButton) {
    // call next screen
    isRecording = !isRecording
    let newImages = isRecording ? UIImage(named: "micStop") : UIImage(named: "micRecord")
    startRecordingButton.setImage(newImages, for: .normal)
    
    isRecording ? core.start() : core.stop()
    
  }
  
}

