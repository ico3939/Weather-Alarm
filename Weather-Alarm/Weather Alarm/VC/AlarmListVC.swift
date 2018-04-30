//
//  AlarmListVC.swift
//  Weather Alarm
//
//  Created by Student on 4/19/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

class AlarmListVC: UIViewController {
    
    // MARK: Outlets
    // -------------
    @IBOutlet var alarmsTableView: UITableView!
    
    //MARK: ivars
    // ----------
    let alarmCell = "AlarmCell"
    let myAddAlarmSegue = "addAlarmSegue" // segue to the add alarm screen
    var alarms = [Alarm]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Alarms"
        
        // load in alarms
        let fileName = "allAlarms.archive"
        let pathToFile = FileManager.filePathInDocumentsDirectory(fileName: fileName)
        
        if FileManager.default.fileExists(atPath: pathToFile.path) {
            print("Opened \(pathToFile)")
            alarms = NSKeyedUnarchiver.unarchiveObject(withFile: pathToFile.path) as! [Alarm]
            print("alarms=\(alarms)")
        }
        
        // set up the cells
        alarmsTableView.dataSource = self
        alarmsTableView.rowHeight = UITableViewAutomaticDimension
        
        let nibName = UINib(nibName: alarmCell, bundle:nil)
        alarmsTableView.register(nibName, forCellReuseIdentifier: alarmCell)
        
        //add navBar elements
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarm))
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let fileName = "allAlarms.archive"
        let pathToFile = FileManager.filePathInDocumentsDirectory(fileName: fileName)
        NSKeyedArchiver.archiveRootObject(self.alarms, toFile: pathToFile.path)
    }
    
    //MARK: ObjC Functions
    // -------------------
    @objc func addAlarm() {
        performSegue(withIdentifier: myAddAlarmSegue, sender: nil)
        
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
        
        print(alarm.isRunning)
        alarm.switchOnOff()
    }
}

