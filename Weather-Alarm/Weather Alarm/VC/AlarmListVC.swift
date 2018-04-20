//
//  AlarmListVC.swift
//  Weather Alarm
//
//  Created by Student on 4/19/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

class AlarmListVC: UITableViewController {
    
    //MARK: ivars
    // ----------
    let alarmCell = "alarmCell"
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
        
    }
    
    //MARK: override functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: alarmCell, for: indexPath)
        let cellHeight: CGFloat = 44.0
        let alarm = alarms[indexPath.row]
        cell.textLabel?.text = alarm.timeOfDay
        
        // create button to activate alarm
        let button: UISwitch = UISwitch()
        button.isSelected = alarm.isRunning
        button.center = CGPoint(x: view.bounds.width - button.frame.width, y: cellHeight / 2.0)
        button.addTarget(self, action: #selector(buttonClicked), for: UIControlEvents.touchUpInside)
        cell.addSubview(button)
        
        return cell
    }
    
    // MARK: objC functions
    // --------------------
    @objc func buttonClicked(sender: Any) {
        //alarm.isRunning = !alarm.isRunning
    }
    
}
