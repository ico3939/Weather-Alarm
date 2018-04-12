//
//  Alarm.swift
//  Weather Alarm
//
//  Created by Student on 4/12/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import CoreLocation
import ForecastIO

class Alarm: NSObject {

    // MARK: ivars
    // -----------
    let client = DarkSkyClient(apiKey: "327180fccdc777b85e2b1fdbb6adab37") // creates a client to use with the api
    let secondsInDay = 86400
    let locationManager: CLLocationManager?
    
    var datePicker: UIDatePicker?
    var currentTimeLeft:Int // the number of seconds remaining
    var startTime:Int // the starting time in seconds
    var isRunning:Bool?
    var timer:Timer?
    
    
    
    // MARK: constructor
    // -----------------
    init(startTime:Int, locationManager: CLLocationManager, datePicker:UIDatePicker) {
        self.startTime = startTime
        self.currentTimeLeft = startTime
        self.locationManager = locationManager
        self.datePicker = datePicker
    }
    
    // MARK: helper functions
    // ----------------------
    func runTimer() {
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func timerComplete() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        getWeatherInfo()
    }
    
    func getWeatherInfo() {
        // Once the user's location is known, the api will check for current weather condition at that location
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self as? CLLocationManagerDelegate
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.startUpdatingLocation()
            print("location = \(String(describing: locationManager?.location))")
            
            client.getForecast(latitude: (locationManager?.location?.coordinate.latitude)!, longitude: (locationManager?.location?.coordinate.longitude)!) { result in
                switch result {
                case .success(let currentForecast, _):
                    // we got the current forecast
                    print("\(String(describing: currentForecast.currently?.summary))")
                    
                    DispatchQueue.main.async(execute: {() -> Void in
                        
                        //TODO: Add in behavior to display weather result
                        //self.weatherLabel.text = currentForecast.currently?.summary
                        
                    })
                case .failure(let error):
                    // there was an error
                    print("\(error)")
                }
            }
        }
    }
    
    //MARK: ObjC Functions
    // -------------------
    @objc func updateTimer() {
        // if time is up
        if currentTimeLeft < 1 {
            timerComplete()
        }
        else {
            currentTimeLeft -= 1 // this will decrement (count down) the seconds
        }
        
        
    }
    
}
