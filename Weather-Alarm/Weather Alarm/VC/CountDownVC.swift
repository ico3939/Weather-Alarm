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
    let weatherManager = WeatherManager()
    let soundManager = SoundManager()
    
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
    
    func saveAlarms() {
        let fileName = "allAlarms.archive"
        let pathToFile = FileManager.filePathInDocumentsDirectory(fileName: fileName)
        let success = NSKeyedArchiver.archiveRootObject(alarms, toFile: pathToFile.path)
        print("Saved = \(success) to \(pathToFile)")
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
        
        
        // TODO: Add functionality for once the timer is finished running
    }
    
    // MARK: IBActions
    // ---------------
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

