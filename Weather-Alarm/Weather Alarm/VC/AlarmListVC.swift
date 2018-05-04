//
//  AlarmListVC.swift
//  Weather Alarm
//
//  Created by Student on 4/19/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import CoreLocation

class AlarmListVC: UITableViewController, AlarmCellDelegate {
    
    // MARK: Outlets
    // -------------
    @IBOutlet var alarmsTableView: UITableView!
    @IBOutlet weak var sunriseSwitch: UISwitch!
    var timeLabel: UILabel!
    var alarmButtonView: UIButton!
    
    
    //MARK: ivars
    // ----------
    let alarmCell = "AlarmCell"
    let myAddAlarmSegue = "addAlarmSegue" // segue to the add alarm screen
    
    var weatherManager:WeatherManager!
    var soundManager: SoundManager!
    var alarms:[Alarm]!
    var runningAlarms: [Alarm]!
    var currentAlarm: Alarm?
    var timer:Timer?
    var selectedRow = IndexPath()
    var isTimeRunning: Bool! // this will be used to make sure only one timer is created at a time
    var isComplete: Bool!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Alarms"
        
        // add gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressRecognizer.view?.becomeFirstResponder()
        self.view?.addGestureRecognizer(longPressRecognizer)

        
        // set up the cells
        alarms.sort{$0.currentTimeLeft < $1.currentTimeLeft}
        alarmsTableView.dataSource = self
        alarmsTableView.rowHeight = UITableViewAutomaticDimension
        
        let nibName = UINib(nibName: alarmCell, bundle:nil)
        alarmsTableView.register(nibName, forCellReuseIdentifier: alarmCell)
        
        // if there is a sunrise alarm, do not include it in the table
        
        for alarm in runningAlarms {
            
            if alarm.timeOfDay == "Sunrise" {
                sunriseSwitch.isOn = true
                break
            }
            else {
                sunriseSwitch.isOn = false
            }
        }
        
        if !isTimeRunning {
            sunriseSwitch.isOn = false
        }
        
        
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
        isComplete = true
        isTimeRunning = false
        alarmButtonView.isHidden = false
        timer?.invalidate()
        currentAlarm?.isRunning = false
        runningAlarms.remove(at: 0)
        
        
        if runningAlarms.count >= 1 {
            currentAlarm = runningAlarms[0]
            currentAlarm?.calcStartSecondsLeft(startTime: (currentAlarm?.startTime)!)
            currentAlarm?.isRunning = true
        }
        
        // TODO: Add behavior for when the timer is finished running
        self.soundManager.playAlarm(soundFileName: self.weatherManager.chooseAlarmBasedOnWeather())
    }
    
    func saveAlarms() {
        let fileName = "allAlarms.archive"
        let pathToFile = FileManager.filePathInDocumentsDirectory(fileName: fileName)
        let success = NSKeyedArchiver.archiveRootObject(alarms, toFile: pathToFile.path)
        print("Saved = \(success) to \(pathToFile)")
    }


    
    // MARK: Overrides
    // ---------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveAlarms()
        
        // passes the alarms from the base view to the list
        if let targetController = segue.destination as? CountdownVC {
            if self.timer != nil {
                targetController.timer = self.timer!
            }
            targetController.alarms = self.alarms
            targetController.runningAlarms = self.runningAlarms
            targetController.currentAlarm = self.currentAlarm
            targetController.isTimeRunning = self.isTimeRunning
            targetController.soundManager = self.soundManager
            targetController.weatherManager = self.weatherManager
            targetController.isComplete = self.isComplete
            
            if currentAlarm == nil {
                targetController.timeLabel.text = targetController.timeString(time: 0)
            }
        }
    }
    
   override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return alarms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: alarmCell, for: indexPath) as! AlarmCell
        let alarm = alarms[indexPath.row]
        
        cell.alarm = alarm
        cell.alarmLabel.text = alarm.timeOfDay
        cell.alarmButton.isOn = alarm.isRunning
        cell.delegate = self
        
        return cell
    }
    
    func alarmButtonClicked(alarm: Alarm) {
        
        alarm.switchOnOff()
        // start running the timer
        if alarm.isRunning {
            
            if alarm.timeOfDay == "Sunrise" {
                sunriseSwitch.setOn(true, animated: true)
            }
            insertNewAlarm(alarm: alarm)
            
        }
        else {
            
            if alarm.timeOfDay == "Sunrise" {
                sunriseSwitch.setOn(false, animated: true)
            }
            
            runningAlarms = runningAlarms.filter({$0 !== alarm})
            
            // remove the alarm from the ones currently running
            if alarm.startTime == currentAlarm?.startTime && !runningAlarms.isEmpty {
                currentAlarm = runningAlarms[0]
                currentAlarm?.calcStartSecondsLeft(startTime: (currentAlarm?.startTime)!)
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
    
    func insertNewAlarm(alarm: Alarm) {
        
        // makes the selected alarm the current one
        if currentAlarm == nil || alarm.currentTimeLeft < (currentAlarm?.currentTimeLeft)!  {
            currentAlarm = alarm
            currentAlarm?.calcStartSecondsLeft(startTime: (currentAlarm?.startTime)!)
            runningAlarms.insert(alarm, at: 0)
            runTimer()
        }
        else {
            // add the alarm to the stack of running timers
            runningAlarms.append(alarm)
            runningAlarms.sort{$0.currentTimeLeft < $1.currentTimeLeft}
            
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if(action == #selector(deleteAlarm)) {
            return true
        }
        else {
            return false
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @IBAction func exitWithCancelTapped(segue: UIStoryboardSegue) {
        print("exitWithCancelTapped")
        saveAlarms()
    }
    
    @IBAction func exitWithDoneTapped(segue: UIStoryboardSegue) {
        print("exitWithDoneTapped")
        // add the alarm to the list and save it
        if let addAlarmVC = segue.source as? AddAlarmVC {
            if let alarm = addAlarmVC.alarm {
                if !alarms.contains(alarm){
                    
                    alarms.append(alarm)
                    alarms.sort{$0.currentTimeLeft < $1.currentTimeLeft}
                    insertNewAlarm(alarm: alarm)
                    let indexPath = IndexPath(row: alarms.index(of: alarm)!, section: 0)
                    self.alarmsTableView.insertRows(at: [indexPath], with: .automatic)
                    saveAlarms()
                }
                else {
                    print("Ignoring alarm of time \(alarm.startTime)")
                }
            }
        }
    }
    
    @IBAction func sunriseSwitchPressed(_ sender: Any) {
        
        if self.sunriseSwitch.isOn {
            let startTime = weatherManager.getNextSunriseTime()
            let sunriseAlarm = Alarm(startTime: startTime, timeOfDay: "Sunrise")
            sunriseAlarm.switchOnOff()
            alarms.append(sunriseAlarm)
            alarms.sort{$0.currentTimeLeft < $1.currentTimeLeft}
            alarmButtonClicked(alarm: sunriseAlarm)
        }
        else {
            
            var sunriseAlarm: Alarm? = Alarm(startTime: 0, timeOfDay: "")
            for alarm in alarms {
                
                if alarm.timeOfDay == "Sunrise" {
                    sunriseAlarm = alarm
                    break
                }
            }

            
            runningAlarms = runningAlarms.filter({$0 !== sunriseAlarm})
            
            // if the deleted alarm was equal to the current one
            if sunriseAlarm?.startTime == currentAlarm?.startTime && !runningAlarms.isEmpty {
                currentAlarm = runningAlarms[0]
                currentAlarm?.calcStartSecondsLeft(startTime: (currentAlarm?.startTime)!)
                runTimer()
            }
            else if runningAlarms.isEmpty{
                timer?.invalidate()
                isTimeRunning = false
                currentAlarm = nil
            }
            
        }
        
    }
    
    
    //MARK: ObjC Functions
    // -------------------
    @objc func addAlarm() {
        performSegue(withIdentifier: myAddAlarmSegue, sender: nil)
        
    }
    
    @objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: longPressGestureRecognizer.view)
            if alarmsTableView.indexPathForRow(at: touchPoint) != nil {
                
                
                // configure the menu item to display
                self.selectedRow = (self.alarmsTableView.indexPathForRow(at: touchPoint))!

                let menuItemTitle = "Delete"
                let action = #selector(deleteAlarm)
                let deleteMenuItem = UIMenuItem(title: menuItemTitle, action: action)
                
                // configure the shared menu controller
                let menuController = UIMenuController.shared
                menuController.menuItems = [deleteMenuItem]
                
                // set the location of the menu in the view
                let menuLocation = CGRect(x: touchPoint.x, y: touchPoint.y, width: 100, height: 50)
                menuController.setTargetRect(menuLocation, in: longPressGestureRecognizer.view!)
                
                // show the menu
                menuController.setMenuVisible(true, animated: true)
                print(menuController.isMenuVisible)
                print(self.selectedRow.row)
            }
        }
    }
    
    @objc func deleteAlarm() {
        // delete the row from the data source
        let removedAlarm = alarms[selectedRow.row]
        
        // if the removed alarm is for sunrise, change the switch as well
        if removedAlarm.timeOfDay == "Sunrise" {
            sunriseSwitch.setOn(false, animated: true)
        }
        
        // adjust the currently running alarms if the deleted one is running
        if removedAlarm.isRunning {
            
            runningAlarms = runningAlarms.filter({$0 !== removedAlarm})

            // if the deleted alarm was equal to the current one
            if removedAlarm.startTime == currentAlarm?.startTime && !runningAlarms.isEmpty {
                currentAlarm = runningAlarms[0]
                currentAlarm?.calcStartSecondsLeft(startTime: (currentAlarm?.startTime)!)
                runTimer()
            }
            else if runningAlarms.isEmpty{
                timer?.invalidate()
                isTimeRunning = false
                currentAlarm = nil
            }
        }
        
        alarms.remove(at: selectedRow.row)
        
        // update the tableView
        self.alarmsTableView.deleteRows(at: [selectedRow], with: .fade)
        saveAlarms()
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
