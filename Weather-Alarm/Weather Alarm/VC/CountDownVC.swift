//
//  ViewController.swift
//  Weather Alarm
//
//  Created by Student on 4/9/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import CoreLocation


class CountdownVC: UIViewController {
    
    // MARK: ivars
    // -----------
    let myAddAlarmSegue = "addAlarmSegue" // segue to the add alarm screen
    let myAlarmListSegue = "alarmListSegue" // segue to the alarm pick screen
    
    var weatherManager = WeatherManager() {
        didSet {
            self.changeBackground(currentWeather: self.weatherManager.currentWeather!)
        }
    }
    var soundManager = SoundManager()
    var currentAlarm:Alarm?
    var alarms = [Alarm]() // an array to hold all saved alarms
    var runningAlarms = [Alarm]()
    var secondsLeft = 0 // this variable will hold a starting value of seconds. It can be any amount above zero
    var timer = Timer()
    var isTimeRunning = false // this will be used to make sure only one timer is created at a time
    var isComplete = false // bool for once a timer is completed
    var soundFilePath: String?
    
    
    // MARK: Outlets
    // -------------
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alarmButtonView: UIButton!
    @IBOutlet weak var setAlarmButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // shows and hides the alarm button once the view is shown
        if !isComplete {
            alarmButtonView.isHidden = true
        }
        else {
            alarmButtonView.isHidden = false
        }
        
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
                alarm.calcStartSecondsLeft(startTime: alarm.startTime) // calculate the current time left for each of the alarms and sort accordingly
                if alarm.isRunning {
                    runningAlarms.append(alarm)
                }
            }
            alarms.sort{$0.currentTimeLeft < $1.currentTimeLeft}
            
            if !runningAlarms.isEmpty {
                print(runningAlarms)
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

        
    }
    
    // MARK: Helper Functions
    // ----------------------
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
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
        isComplete = true
        isTimeRunning = false
        alarmButtonView.isHidden = false
        timer.invalidate()
        currentAlarm?.isRunning = false
        runningAlarms.remove(at: 0)
        
        
        if runningAlarms.count >= 1 {
            currentAlarm = runningAlarms[1]
            currentAlarm?.calcStartSecondsLeft(startTime: (currentAlarm?.startTime)!)
            currentAlarm?.isRunning = true
            runTimer()
        }
        
        
        // TODO: Add functionality for once the timer is finished running
        self.soundManager.playAlarm(soundFileName: self.weatherManager.chooseAlarmBasedOnWeather())
        self.alarmButtonView.isHidden = false
    }
    
    func changeBackground(currentWeather: String) {
        if currentWeather == "clear-day" || currentWeather == "clear-night" || currentWeather == "partly-cloudy-day" || currentWeather == "partly-cloudy-night" {
            
            self.backgroundImage.image = #imageLiteral(resourceName: "gradient-sunny")
            
        }
        else if currentWeather == "cloudy" || currentWeather == "fog" {
            
            self.backgroundImage.image = #imageLiteral(resourceName: "gradient-cloudy")
        }
        else if currentWeather == "rain"{
            
            self.backgroundImage.image = #imageLiteral(resourceName: "gradient-stormy")
            
        }
        else if currentWeather == "thunderstorm" || currentWeather == "tornado" || currentWeather == "hail" {
            self.backgroundImage.image = #imageLiteral(resourceName: "gradient-stormy")
            
        }
        else if currentWeather == "snow" || currentWeather == "sleet" {
            
            self.backgroundImage.image = #imageLiteral(resourceName: "gradient-snowy")
            
        }
        else if currentWeather == "windy" {
            
            self.backgroundImage.image = #imageLiteral(resourceName: "gradient-windy")
            
        }
        
    }
    
    // MARK: IBActions
    // ---------------
    @IBAction func unwindWithBackTapped(segue: UIStoryboardSegue) {
        print("unwindWithCancelTapped")
    }
    
    
    @IBAction func setAlarmButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: myAlarmListSegue, sender: nil)
    }
    
    @IBAction func turnOffAlarm(_ sender: Any) {
        alarmButtonView.isHidden = true
        isComplete = false
        soundManager.stopAlarm()
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
            targetController.soundManager = self.soundManager
            targetController.weatherManager = self.weatherManager
            targetController.isComplete = self.isComplete
            targetController.alarmButtonView = self.alarmButtonView

        }
    }
    
    
    //MARK: ObjC Functions
    // -------------------
    
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

