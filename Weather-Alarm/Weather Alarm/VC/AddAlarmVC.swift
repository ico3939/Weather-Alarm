//
//  AddAlarmsVC.swift
//  Weather Alarm
//
//  Created by Student on 4/17/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

class AddAlarmVC: UIViewController {
    
    // ivars
    // -----
    let secondsInDay = 86400
    var alarm:Alarm?
    
    // MARK: Outlets
    // -------------
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Alarm"
        
        // initialize the dateTimePicker
        datePicker.datePickerMode = UIDatePickerMode.time

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let startTime = datePicker.date
        print(startTime)
        let timeOfDay = timeOfDayString(time: startTime)
        
        let currentDate = Date()
        let cal = Calendar(identifier: .gregorian)
        let midnight = cal.startOfDay(for: currentDate)

        
        var startTimeSeconds = Int(startTime.timeIntervalSince(midnight))
        
        if startTimeSeconds % 60 != 0 {
            let remainder = startTimeSeconds % 60
            startTimeSeconds -= remainder
        }
        
        print(startTimeSeconds)
        
        alarm = Alarm(startTime: startTimeSeconds, timeOfDay: timeOfDay)
    }
    
    // MARK: helper functions
    // ----------------------
    func timeOfDayString(time:Date) -> String {
        var amPM:String = "am"
        let calender = Calendar.current
        var hours = calender.component(.hour, from: time)
        
        if hours >= 12 {
            amPM = "pm"
            if hours > 12 {
                hours -= 12
            }
        }
        if hours == 0 {
            hours = 12
        }
        
        let minutes = calender.component(.minute, from: time)
        var minuteString = String(minutes)
        if minutes < 10 {
            minuteString = "0\(minuteString)"
        }
        return "\(hours):\(minuteString)\(amPM)"
    }
    
    
}
