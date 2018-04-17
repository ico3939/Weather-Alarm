//
//  ViewController.swift
//  Weather Alarm
//
//  Created by Student on 4/9/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import CoreLocation
import ForecastIO
import AVFoundation


class CountdownVC: UIViewController {
    
    // MARK: ivars
    // -----------
    let myAddAlarmSegue = "addAlarmSegue"
    let client = DarkSkyClient(apiKey: "327180fccdc777b85e2b1fdbb6adab37") // creates a client to use with the api
    let locationManager = CLLocationManager()
    let startTime = 10
    let secondsInDay = 86400
    let player = AVAudioPlayer()
    
    var alarm:Alarm?
    var alarms = [Alarm?]() // an array to hold all saved alarms
    var seconds = 0 // this variable will hold a starting value of seconds. It can be any amount above zero
    var timer = Timer()
    var isTimeRunning = false // this will be used to make sure only one timer is created at a time
    
    
    // MARK: Outlets
    // -------------
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // instantiate the CLLocationManager class
        //----------------------------------------
        self.locationManager.requestAlwaysAuthorization() // Ask for Authorisation from the User
        self.locationManager.requestWhenInUseAuthorization() // For use in foreground
        
        seconds = startTime // set the start time
        self.timeLabel.text = alarm?.timeString(time: TimeInterval(seconds))
        
        // initialize the dateTimePicker
        datePicker.datePickerMode = UIDatePickerMode.time
        
        self.alarm = Alarm(startTime: self.startTime, timeOfDay: timeOfDayString(time: TimeInterval(self.startTime)), locationManager: self.locationManager, datePicker: self.datePicker, player: self.player, weatherLabel: self.weatherLabel, timeLabel: self.timeLabel)
        
        //add navBar elements
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarm))

        
    }
    
    // MARK: Helper Functions
    // ----------------------
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
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
    
    
    // MARK: IBActions
    // ---------------
    @IBAction func startButtonTapped(_ sender: Any) {
        if isTimeRunning == false {
            alarm?.runTimer()
            startButton.isEnabled = false
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        
        seconds = startTime // here we manually enter the restarting point for seconds
        
        self.timeLabel.text = alarm?.timeString(time: TimeInterval(seconds))
        alarm?.runTimer()
    }
    
    @IBAction func dateChosen(_ sender: Any) {
        seconds = Int(datePicker.date.timeIntervalSinceNow)
        if seconds < 0 {
            seconds += secondsInDay
        }
        timeLabel.text = alarm?.timeString(time: TimeInterval(seconds))
    }
    
    @IBAction func unwindWithCancel(_ sender: Any) {
    }
    
    @IBAction func unwindWithDone(_ sender: Any) {
    }
    
    //MARK: ObjC Functions
    // -------------------
    @objc func addAlarm() {
        performSegue(withIdentifier: myAddAlarmSegue, sender: nil)
        
    }
    
    
}

