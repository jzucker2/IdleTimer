//
//  ViewController.swift
//  IdleTimer
//
//  Created by Jordan Zucker on 01/25/2017.
//  Copyright (c) 2017 Jordan Zucker. All rights reserved.
//

import UIKit
import IdleTimer

class ViewController: UIViewController {
    
    class SubTimer: IdleTimer {
        override class var defaultScreenState: ScreenState {
            return ScreenState.awake
        }
        static let shared = SubTimer()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("current: \(SubTimer.defaultScreenState.title)")
        print("current: \(SubTimer.shared.currentScreenStateTitle)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

