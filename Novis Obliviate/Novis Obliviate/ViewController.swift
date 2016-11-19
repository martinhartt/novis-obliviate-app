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
    
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
    @IBAction func startRecording(startRecording : UIButton) {
        // call next screen
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RecordingViewController")
        self.present(viewController!, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startRecording(sender: UIButton) {
    
        guard let recorder = recorder else { return }
        
        if recorder.isRecording {
            sender.setTitle("Start recording", for: .normal)
            recorder.stop()
        } else {
            sender.setTitle("Stop recording", for: .normal)
            recorder.start()
        }
    }
}

