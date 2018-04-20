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
    var isScrolling = false
    
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
        var startTime = Int(datePicker.date.timeIntervalSinceNow)
        if startTime < 0 {
            startTime += secondsInDay
        }
        let timeOfDay = timeOfDayString(time: TimeInterval(startTime))
        alarm = Alarm(startTime: startTime, timeOfDay: timeOfDay)
    }
    
    // MARK: helper functions
    // ----------------------
    func timeOfDayString(time:TimeInterval) -> String {
        var amPM:String = "am"
        var hours = Int(time) / 3600
        
        if hours >= 12 {
            amPM = "pm"
            if hours > 12 {
                hours -= 12
            }
        }
        let minutes = Int(time) / 60 % 60
        return "\(hours):\(minutes)\(amPM)"
    }
    
}
