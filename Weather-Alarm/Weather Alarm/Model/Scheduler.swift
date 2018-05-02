//
//  Scheduler.swift
//  Weather Alarm
//
//  Created by Student on 5/1/18.
//  Copyright © 2018 Student. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class Scheduler: AlarmSchedulerDelegate {
    var alarmModel
    
    func setNotificationWithDate(_ date: Date, snoozeEnabled: Bool, onSnooze: Bool, soundName: String, index: Int) {
        <#code#>
    }
    
    func setNotificationForSnooze(snoozeMinute: Int, soundName: String, index: Int) {
        <#code#>
    }
    
    func setupNotificationSettings() -> UNNotificationSettings {
        <#code#>
    }
    
    func reSchedule() {
        <#code#>
    }
    
    func checkNotification() {
        <#code#>
    }
    
    
}
