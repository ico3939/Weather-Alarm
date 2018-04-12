//
//  Alarm.swift
//  Weather Alarm
//
//  Created by Student on 4/12/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import CoreLocation
import ForecastIO

class Alarm: NSObject {

    // MARK: ivars
    // -----------
    let secondsInDay = 86400
    var currentTimeLeft = 0 // the number of seconds remaining
    var startTime = 0 // the starting time in seconds
    var isRunning:Bool?
    var timer = Timer()
    
    
    // MARK: constructor
    // -----------------
    init(startTime:Int) {
        self.startTime = startTime
        self.currentTimeLeft = startTime
    }
    
    // MARK: helper functions
    // ----------------------
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func timerComplete() {
        isRunning = false
        timer.invalidate()
    }
    
    //MARK: ObjC Functions
    // -------------------
    @objc func updateTimer() {
        // if time is up
        if currentTimeLeft < 1 {
            timerComplete()
        }
        else {
            currentTimeLeft -= 1 // this will decrement (count down) the seconds
        }
        
        
    }
    
}
