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


class ViewController: UIViewController {
    
    // MARK: ivars
    // -----------
    let client = DarkSkyClient(apiKey: "327180fccdc777b85e2b1fdbb6adab37") // creates a client to use with the api
    let locationManager = CLLocationManager()
    let startTime = 10
    let secondsInDay = 86400
    let player = AVAudioPlayer()
    
    var alarm = Alarm()
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
        self.timeLabel.text = alarm.timeString(time: TimeInterval(seconds))
        
        // initialize the dateTimePicker
        datePicker.datePickerMode = UIDatePickerMode.time
        
        self.alarm = Alarm(startTime: self.startTime, locationManager: self.locationManager, datePicker: self.datePicker, player: self.player, weatherLabel: self.weatherLabel, timeLabel: self.timeLabel)
        

        
    }
    
    // MARK: Helper Functions
    // ----------------------
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    
    // MARK: IBActions
    // ---------------
    @IBAction func startButtonTapped(_ sender: Any) {
        if isTimeRunning == false {
            alarm.runTimer()
            startButton.isEnabled = false
        }
        
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        
        seconds = startTime // here we manually enter the restarting point for seconds
        
        self.timeLabel.text = alarm.timeString(time: TimeInterval(seconds))
        alarm.runTimer()
    }
    
    @IBAction func dateChosen(_ sender: Any) {
        seconds = Int(datePicker.date.timeIntervalSinceNow)
        if seconds < 0 {
            seconds += secondsInDay
        }
        timeLabel.text = alarm.timeString(time: TimeInterval(seconds))
    }
    
    
}

