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
    var selectedRow = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Alarms"
        
        // add gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
        
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

    
    // MARK: Overrides
    // ---------------
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

