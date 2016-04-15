//
//  ViewController.swift
//  ButtonExperiment
//
//  Created by Oscar Apeland on 13.04.2016.
//  Copyright © 2016 Ways AS. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {
    var s = false
    @IBOutlet weak var button: ProgressButton!
    var percent = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        NSTimer.every(0.1.seconds) { (timer: NSTimer) in
            self.percent += 0.1
            self.button.loading(self.percent)
            if self.percent >= 1.0 {
                self.button.loadingDone()

                timer.invalidate()
                self.percent = 0.0
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

