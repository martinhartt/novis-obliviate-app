//
//  RecordingViewControlle.swift
//  Novis Obliviate
//
//  Created by luxman Elangeswaralingam on 19/11/2016.
//  Copyright © 2016 Novis Obliviate Ltd. All rights reserved.
//
import UIKit

class RecordingViewController: UIViewController {
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    @IBOutlet weak var stopRecordingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func stopRecordingButton(stopRecordingButton : UIButton) {
            // call back the old screen
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
            self.present(viewController!, animated: true, completion: nil)
        }
        

    }
