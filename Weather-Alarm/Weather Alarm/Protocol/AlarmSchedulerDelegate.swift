//
//  AlarmSchedulerDelegate.swift
//  Weather Alarm
//
//  Created by Student on 5/1/18.
//  Copyright © 2018 Student. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

protocol AlarmSchedulerDelegate {
    func setNotificationWithDate(_ date: Date, snoozeEnabled: Bool, onSnooze: Bool, soundName: String, index: Int)
    // helper functions
    func setNotificationForSnooze(snoozeMinute: Int, soundName: String, index: Int)
    func setupNotificationSettings() -> UNNotificationSettings
    func reSchedule()
    func checkNotification()
}
