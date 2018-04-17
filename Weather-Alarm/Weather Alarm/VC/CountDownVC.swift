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
    
    var currentAlarm:Alarm?
    var alarms = [Alarm?]() // an array to hold all saved alarms
    var secondsLeft = 0 // this variable will hold a starting value of seconds. It can be any amount above zero
    var timer = Timer()
    var isTimeRunning = false // this will be used to make sure only one timer is created at a time
    
    
    // MARK: Outlets
    // -------------
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var weatherLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // instantiate the CLLocationManager class
        //----------------------------------------
        self.locationManager.requestAlwaysAuthorization() // Ask for Authorisation from the User
        self.locationManager.requestWhenInUseAuthorization() // For use in foreground
        
        // load in alarms
        let fileName = "allAlarms.archive"
        let pathToFile = FileManager.filePathInDocumentsDirectory(fileName: fileName)
        
        if FileManager.default.fileExists(atPath: pathToFile.path) {
            print("Opened \(pathToFile)")
            alarms = NSKeyedUnarchiver.unarchiveObject(withFile: pathToFile.path) as! [Alarm]
            print("alarms=\(alarms)")
        }
        else {
            
        }
        
        secondsLeft = startTime // set the start time
        self.timeLabel.text = timeString(time: TimeInterval(secondsLeft))
        
        //add navBar elements
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarm))

        
    }
    
    // MARK: Helper Functions
    // ----------------------
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func saveAlarms() {
        let fileName = "allAlarms.archive"
        let pathToFile = FileManager.filePathInDocumentsDirectory(fileName: fileName)
        let success = NSKeyedArchiver.archiveRootObject(alarms, toFile: pathToFile.path)
        print("Saved = \(success) to \(pathToFile)")
    }
    
    func getWeatherInfo() {
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
                    
                    DispatchQueue.main.async(execute: {() -> Void in
                        
                        //TODO: Add in behavior to display weather result
                        self.weatherLabel?.text = (currentForecast.currently?.icon).map { $0.rawValue }
                        
                    })
                case .failure(let error):
                    // there was an error
                    print("\(error)")
                    return
                }
            }
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func runTimer() {
        isTimeRunning = true
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func timerComplete() {
        isTimeRunning = false
        timer.invalidate()
        
        getWeatherInfo()
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
        
        secondsLeft = startTime // here we manually enter the restarting point for seconds
        
        self.timeLabel.text = timeString(time: TimeInterval(secondsLeft))
        runTimer()
    }
    
    
    @IBAction func unwindWithCancelTapped(segue: UIStoryboardSegue) {
        print("unwindWithCancelTapped")
    }
    
    @IBAction func unwindWithDoneTapped(segue: UIStoryboardSegue) {
        print("unwindWithDoneTapped")
        // add the alarm to the list and save it
        if let addAlarmVC = segue.source as? AddAlarmVC {
            if let alarm = addAlarmVC.alarm {
                alarms.append(alarm)
                saveAlarms()
                
                print(alarms)
            }
        }
    }
    
    
    //MARK: ObjC Functions
    // -------------------
    @objc func addAlarm() {
        performSegue(withIdentifier: myAddAlarmSegue, sender: nil)
        
    }
    
    @objc func updateTimer() {
        // if time is up
        if secondsLeft < 1 {
            timerComplete()
        }
        else {
            secondsLeft -= 1 // this will decrement (count down) the seconds
            self.timeLabel?.text = self.timeString(time: TimeInterval(secondsLeft)) // this will update the label
        }
    }
    
    
}

