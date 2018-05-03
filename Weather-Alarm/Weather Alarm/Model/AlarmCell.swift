//
//  AlarmCell.swift
//  Weather Alarm
//
//  Created by Student on 4/29/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

// Delegate Protocol to communicate
protocol AlarmCellDelegate {
    
    // standard delegate naming convention
    func alarmButtonClicked(alarm: Alarm)
}

class AlarmCell: UITableViewCell {

    var delegate: AlarmCellDelegate?
    var alarm: Alarm?
    

    // MARK: IBOutlets
    // ---------------
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var alarmButton: UISwitch!
    
    @IBAction func onOffButtonPressed(_ sender: Any) {
        print("switch pressed")
        
        delegate?.alarmButtonClicked(alarm: self.alarm!)
    }
    
}
