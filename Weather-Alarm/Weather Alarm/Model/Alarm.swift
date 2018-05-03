//
//  Alarm.swift
//  Weather Alarm
//
//  Created by Student on 4/12/18.
//  Copyright © 2018 Student. All rights reserved.
//

import Foundation

class Alarm: NSObject, NSCoding {
    
    // MARK: ivars
    // -----------
    var currentTimeLeft:Int = 0// the number of seconds remaining
    let startTime:Int // the starting time in seconds
    let timeOfDay:String // a readable string describing the startTime in terms of the time of day
    var isRunning:Bool
    
    // MARK: constructor
    // -----------------
    init(startTime:Int, timeOfDay:String) {
        self.startTime = startTime
        self.timeOfDay = timeOfDay
        self.isRunning = true
        
        // set up the initial seconds remaining
        let currentDate = Date()
        let cal = Calendar(identifier: .gregorian)
        let currentHours = cal.component(.hour, from: currentDate)
        let currentMinutes = cal.component(.minute, from: currentDate)
        var currentSeconds = cal.component(.second, from: currentDate)
        
        currentSeconds += (currentMinutes * 60) + (currentHours * 3600)
        
        if currentSeconds < startTime {
            self.currentTimeLeft = startTime - currentSeconds
        }
        else {
            self.currentTimeLeft = 86400 - (currentSeconds - startTime)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        startTime = aDecoder.decodeInteger(forKey: "startTime")
        timeOfDay = aDecoder.decodeObject(forKey: "timeOfDay") as! String
        self.currentTimeLeft = startTime
        isRunning = aDecoder.decodeBool(forKey: "isRunning")
        
        // set up the initial seconds remaining
        let currentDate = Date()
        let cal = Calendar(identifier: .gregorian)
        let currentHours = cal.component(.hour, from: currentDate)
        let currentMinutes = cal.component(.minute, from: currentDate)
        var currentSeconds = cal.component(.second, from: currentDate)
        
        currentSeconds += (currentMinutes * 60) + (currentHours * 3600)
        
        if currentSeconds < startTime {
            self.currentTimeLeft = startTime - currentSeconds
        }
        else {
            self.currentTimeLeft = 86400 - (currentSeconds - startTime)
        }
        
    }
    
    
    // MARK: helper functions
    // ----------------------
    func switchOnOff() {
        self.isRunning = !self.isRunning
        
    }
    
    func calcStartSecondsLeft(startTime: Int){
        
        let currentDate = Date()
        let cal = Calendar(identifier: .gregorian)
        let currentHours = cal.component(.hour, from: currentDate)
        let currentMinutes = cal.component(.minute, from: currentDate)
        var currentSeconds = cal.component(.second, from: currentDate)
        
        currentSeconds += (currentMinutes * 60) + (currentHours * 3600)
        
        if currentSeconds < startTime {
            self.currentTimeLeft = startTime - currentSeconds
        }
        else {
            self.currentTimeLeft = 86400 - (currentSeconds - startTime)
        }
    }

    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
   
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(timeOfDay, forKey: "timeOfDay")
        aCoder.encode(isRunning, forKey: "isRunning")
    }
    
    
    override func isEqual(_ object: Any?) -> Bool {
        if let alarm = object as? Alarm {
            if self.startTime == alarm.startTime {
                return true
            }
        }
        return false
    }
}
