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


class ViewController: UIViewController {
    
    // MARK: ivars
    // -----------
    let client = DarkSkyClient(apiKey: "327180fccdc777b85e2b1fdbb6adab37") // creates a client to use with the api
    let locationManager = CLLocationManager()
    let startTime = 10
    
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
        self.timeLabel.text = timeString(time: TimeInterval(seconds))
        
    }
    
    // MARK: Helper Functions
    // ----------------------
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    @objc func updateTimer() {
        // if time is up
        if seconds < 1 {
            timerComplete()
        }
        else {
            seconds -= 1 // this will decrement (count down) the seconds
            self.timeLabel.text = timeString(time: TimeInterval(seconds)) // this will update the label
        }

        
    }
    
    func timerComplete() {
        timer.invalidate()
        startButton.isEnabled = true
        // TODO: This is where the logic for getting the current weather and playing the subsequent tone will go
        
        // Once the user's location is known, the api will check for current weather condition at that location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            print("location = \(String(describing: locationManager.location))")
            
            client.getForecast(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!) { result in
                switch result {
                case .success(let currentForecast, _):
                    // we got the current forecast
                    print("\(String(describing: currentForecast.currently?.summary))")
                    self.weatherLabel.text = currentForecast.currently?.summary
                case .failure(let error):
                    // there was an error
                    print("\(error)")
                }
            }
        }
    }
    
    // MARK: IBActions
    // ---------------
    @IBAction func startButtonTapped(_ sender: Any) {
        if isTimeRunning == false {
            runTimer()
            startButton.isEnabled = false
        }
        
    }
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        
        seconds = startTime // here we manually enter the restarting point for seconds
        
        self.timeLabel.text = timeString(time: TimeInterval(seconds))
        
    }
    @IBAction func dateChosen(_ sender: Any) {
        print("\(datePicker.countDownDuration)")
        
        seconds = Int(datePicker.countDownDuration)
        timeLabel.text = timeString(time: TimeInterval(seconds))
    }
    
    
}

