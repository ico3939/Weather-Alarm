//
//  AlarmListVC.swift
//  Weather Alarm
//
//  Created by Student on 4/19/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import CoreLocation
import ForecastIO
import AVFoundation

class AlarmListVC: UIViewController {
    
    // MARK: Outlets
    // -------------
    @IBOutlet var alarmsTableView: UITableView!
    var timeLabel: UILabel!
    
    //MARK: ivars
    // ----------
    let alarmCell = "AlarmCell"
    let myAddAlarmSegue = "addAlarmSegue" // segue to the add alarm screen
    let client = DarkSkyClient(apiKey: "327180fccdc777b85e2b1fdbb6adab37") // creates a client to use with the api
    let locationManager = CLLocationManager()
    let player = AVAudioPlayer()
    
    var alarms:[Alarm]!
    var runningAlarms: [Alarm]!
    var currentAlarm: Alarm!
    var timer:Timer!
    var selectedRow = IndexPath()
    var isTimeRunning: Bool! // this will be used to make sure only one timer is created at a time

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Alarms"
        
        // add gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.view.addGestureRecognizer(longPressRecognizer)

        
        // set up the cells
        alarmsTableView.dataSource = self
        alarmsTableView.rowHeight = UITableViewAutomaticDimension
        
        let nibName = UINib(nibName: alarmCell, bundle:nil)
        alarmsTableView.register(nibName, forCellReuseIdentifier: alarmCell)
        
        //add navBar elements
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarm))
        
    }
    
    //MARK: Helper functions
    // ---------------------
    func runTimer() {
        isTimeRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func timerComplete() {
        isTimeRunning = false
        timer?.invalidate()
        currentAlarm?.isRunning = false
        
        // TODO: Add behavior for when the timer is finished running
        getWeatherInfo()
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
                        
                        
                    })
                case .failure(let error):
                    // there was an error
                    print("\(error)")
                    return
                }
            }
        }
    }

    
    // MARK: Overrides
    // ---------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let fileName = "allAlarms.archive"
        let pathToFile = FileManager.filePathInDocumentsDirectory(fileName: fileName)
        NSKeyedArchiver.archiveRootObject(self.alarms, toFile: pathToFile.path)
        
        
        // passes the alarms from the base view to the list
        if let targetController = segue.destination as? CountdownVC {
            targetController.timer = self.timer
            targetController.runningAlarms = self.runningAlarms
            targetController.currentAlarm = self.currentAlarm
            targetController.isTimeRunning = self.isTimeRunning
            
            if currentAlarm == nil {
                targetController.timeLabel.text = targetController.timeString(time: 0)
            }
        }
    }
    
    //MARK: ObjC Functions
    // -------------------
    @objc func addAlarm() {
        performSegue(withIdentifier: myAddAlarmSegue, sender: nil)
        
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: longPressGestureRecognizer.view)
            if alarmsTableView.indexPathForRow(at: touchPoint) != nil {
                
                
                // configure the menu item to display
                self.selectedRow = (self.alarmsTableView.indexPathForRow(at: touchPoint))!

                let menuItemTitle = NSLocalizedString("Delete", comment: "Delete the selected alarm")
                let action = #selector(deleteAlarm)
                let deleteMenuItem = UIMenuItem(title: menuItemTitle, action: action)
                
                // configure the shared menu controller
                let menuController = UIMenuController.shared
                menuController.menuItems = [deleteMenuItem]
                
                // set the location of the menu in the view
                let menuLocation = CGRect(x: touchPoint.x, y: touchPoint.y, width: 0, height: 0)
                menuController.setTargetRect(menuLocation, in: self.view)
                
                // show the menu
                menuController.setMenuVisible(true, animated: true)
            }
        }
    }
    
    @objc func deleteAlarm() {
        // delete the row from the data source
        alarms.remove(at: selectedRow.row)
        
        // update the tableView
        self.alarmsTableView.deleteRows(at: [selectedRow], with: .fade)
        let fileName = "allAlarms.archive"
        let pathToFile = FileManager.filePathInDocumentsDirectory(fileName: fileName)
        NSKeyedArchiver.archiveRootObject(self.alarms, toFile: pathToFile.path)
    }
    
    @objc func updateTimer() {
        // if time is up
        if (self.currentAlarm?.currentTimeLeft)! < 1 {
            
            timerComplete()
        }
        else {
            self.currentAlarm?.currentTimeLeft -= 1 // this will decrement (count down) the seconds
            self.timeLabel?.text = self.currentAlarm?.timeString(time: TimeInterval((self.currentAlarm?.currentTimeLeft)!)) // this will update the label
        }
    }
    
}

// MARK: Extensions
// ----------------
extension AlarmListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: alarmCell, for: indexPath) as! AlarmCell
        let alarm = alarms[indexPath.row]
        cell.alarm = alarm
        cell.alarmLabel.text = alarm.timeOfDay
        cell.alarmButton.isOn = alarm.isRunning
        cell.delegate = self
        

        return cell
    }
    
}

extension AlarmListVC: AlarmCellDelegate {
    
    func alarmButtonClicked(alarm: Alarm) {
        
        alarm.switchOnOff()
        // start running the timer
        if alarm.isRunning {
            
            // makes the selected alarm the current one
            if currentAlarm == nil || alarm.currentTimeLeft < (currentAlarm?.currentTimeLeft)!  {
                currentAlarm = alarm
                print(currentAlarm.timeOfDay)
                currentAlarm.calcStartSecondsLeft(startTime: currentAlarm.startTime)
                runningAlarms.insert(alarm, at: 0)
                runTimer()
            }
            else {
                // add the alarm to the stack of running timers
                runningAlarms.append(alarm)
                runningAlarms.sort{$0.currentTimeLeft < $1.currentTimeLeft}
                
            }
            
        }
        else {
            
            runningAlarms = runningAlarms.filter({$0 !== alarm})
            
            // remove the alarm from the ones currently running
            if alarm.startTime == currentAlarm.startTime && !runningAlarms.isEmpty {
                currentAlarm = runningAlarms[0]
                currentAlarm.calcStartSecondsLeft(startTime: currentAlarm.startTime)
                runTimer()
            }
            
            // stop the timer if there are no more alarms that are on
            else if runningAlarms.isEmpty {
                timer?.invalidate()
                isTimeRunning = false
                currentAlarm = nil
    
            }
        }
        
    }
}

