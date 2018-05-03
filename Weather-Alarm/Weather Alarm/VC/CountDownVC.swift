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
    let myAddAlarmSegue = "addAlarmSegue" // segue to the add alarm screen
    let myAlarmListSegue = "alarmListSegue" // segue to the alarm pick screen
    let client = DarkSkyClient(apiKey: "327180fccdc777b85e2b1fdbb6adab37") // creates a client to use with the api
    let locationManager = CLLocationManager()
    let player: AVAudioPlayer = {
        
        var path = Bundle.main.path(forResource: "Vivaldi - The_Four_Seasons - Spring_Mvt_1_Allegro-(clear)", ofType: "mp3")!
        let url = NSURL(fileURLWithPath: path)
        let p = try! AVAudioPlayer(contentsOf: url as URL)
        p.prepareToPlay()
        return p
    }()
    
    var currentAlarm:Alarm?
    var alarms = [Alarm]() // an array to hold all saved alarms
    var runningAlarms = [Alarm]()
    var secondsLeft = 0 // this variable will hold a starting value of seconds. It can be any amount above zero
    var timer = Timer()
    var isTimeRunning = false // this will be used to make sure only one timer is created at a time
    var soundFilePath: String?
    
    
    // MARK: Outlets
    // -------------
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var setAlarmButton: UIBarButtonItem!
    
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
        
        // determine which of the saved alarms are currently running
        if !alarms.isEmpty{
            
            for alarm in alarms {
                if alarm.isRunning {
                    runningAlarms.append(alarm)
                }
            }
            
            if !runningAlarms.isEmpty {
                runningAlarms.sort{$0.currentTimeLeft < $1.currentTimeLeft}
                currentAlarm = runningAlarms[0]
                
                secondsLeft = (currentAlarm?.currentTimeLeft)! // set the start time
                runTimer()
            }
            else {
                secondsLeft = 0
            }
            
        }
        else {
            secondsLeft = 0
        }
        
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
                        //self.weatherLabel?.text = (currentForecast.currently?.icon).map { $0.rawValue }
                        let currentWeather = (currentForecast.currently?.icon).map { $0.rawValue }
                        
                        if currentWeather == "clear-day" || currentWeather == "clear-night" || currentWeather == "partly-cloudy-day" || currentWeather == "partly-cloudy-night" {
                            
                        }
                        else if currentWeather == "cloudy" || currentWeather == "fog" {
                            
                        }
                        else if currentWeather == "rain" || currentWeather == "thunderstorm" || currentWeather == "tornado" || currentWeather == "hail"{
                            
                        }
                        else if currentWeather == "snow" || currentWeather == "sleet" {
                            
                        }
                        else if currentWeather == "windy" {
                            
                        }
                        
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
        currentAlarm?.isRunning = false
        getWeatherInfo()
    }
    
    // MARK: IBActions
    // ---------------
    @IBAction func unwindWithCancelTapped(segue: UIStoryboardSegue) {
        print("unwindWithCancelTapped")
        saveAlarms()
        
    }
    
    @IBAction func unwindWithDoneTapped(segue: UIStoryboardSegue) {
        print("unwindWithDoneTapped")
        // add the alarm to the list and save it
        if let addAlarmVC = segue.source as? AddAlarmVC {
            if let alarm = addAlarmVC.alarm {
                if !alarms.contains(alarm) {
                    
                    alarms.append(alarm)
                    alarms.sort{$0.startTime < $1.startTime}
                    saveAlarms()
                    
                    print("adding alarm")
                    print(timeString(time: TimeInterval(alarm.startTime)))
                }
                else {
                    print("Ignoring alarm of time \(alarm.startTime)")
                }
            }
        }
    }
    
    @IBAction func setAlarmButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: myAlarmListSegue, sender: nil)
    }
    
    
    //MARK: Overrides
    // --------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNavigationController = segue.destination as! UINavigationController
        
        // passes the alarms from the base view to the list
        if let targetController = destinationNavigationController.topViewController as? AlarmListVC {
            targetController.alarms = self.alarms
            targetController.timer = self.timer
            targetController.timeLabel = self.timeLabel
            targetController.currentAlarm = self.currentAlarm
            targetController.runningAlarms = self.runningAlarms
            targetController.isTimeRunning = self.isTimeRunning
        }
    }
    
    
    //MARK: ObjC Functions
    // -------------------
    @objc func addAlarm() {
        performSegue(withIdentifier: myAddAlarmSegue, sender: nil)
        
    }
    
    @objc func updateTimer() {
        // if time is up
        if (self.currentAlarm?.currentTimeLeft)! < 1 {
            
            timerComplete()
        }
        else {
            self.currentAlarm?.currentTimeLeft -= 1 // this will decrement (count down) the seconds
            self.timeLabel?.text = self.timeString(time: TimeInterval((self.currentAlarm?.currentTimeLeft)!)) // this will update the label
        }
    }
    
    
}

extension UIViewController {
    func performSegueToReturnBack() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

