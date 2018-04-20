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
    let currentTimeLeft:Int // the number of seconds remaining
    let startTime:Int // the starting time in seconds
    let timeOfDay:String // a readable string describing the startTime in terms of the time of day
    var isRunning:Bool
    
    // MARK: constructor
    // -----------------
    init(startTime:Int, timeOfDay:String) {
        self.startTime = startTime
        self.currentTimeLeft = startTime
        self.timeOfDay = timeOfDay
        self.isRunning = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        startTime = aDecoder.decodeInteger(forKey: "startTime")
        timeOfDay = aDecoder.decodeObject(forKey: "timeOfDay") as! String
        self.currentTimeLeft = startTime
        self.isRunning = false
    }
    
    
    // MARK: helper functions
    // ----------------------
   
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(startTime, forKey: "startTime")
        aCoder.encode(timeOfDay, forKey: "timeOfDay")
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
