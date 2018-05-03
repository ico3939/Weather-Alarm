//
//  WeatherManager.swift
//  Weather Alarm
//
//  Created by Student on 5/2/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit
import ForecastIO
import CoreLocation

class WeatherManager: NSObject {
    
    // MARK: ivars
    // -----------
    var client = DarkSkyClient(apiKey: "5a58a30e4b84061571f5368dc89eacb5")
    var locationManager = CLLocationManager()
    
    var forecast: Forecast?
    var currentWeather: String?
    var isDelegateSet: Bool!
    var currentTemperature: Int?
    
    // MARK: Constructor
    // -----------------
    override init() {
        super.init()
        
        // instantiate the CLLocationManager class
        //----------------------------------------
        self.locationManager.requestAlwaysAuthorization() // Ask for Authorisation from the User
        self.locationManager.requestWhenInUseAuthorization() // For use in foreground
        
        self.isDelegateSet = self.delegateIsSet()
    }
    
    
    // MARK: Helper Functions
    // ----------------------
    func getWeatherInfo(date: Date, isDataBlock: Bool) {
        
        // Once the user's location is known, the api will check for current weather condition at that location
        if isDataBlock {
            
            self.client.getForecast(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, completion: { result in
                switch result {
                case .success(let currentForecast, _):
                    // we got the current forecast
                    print("\(String(describing: currentForecast.currently?.icon?.rawValue))")
                    self.forecast = currentForecast
                    self.currentWeather = (self.forecast?.currently?.icon).map { $0.rawValue }
                    self.currentTemperature = Int((self.forecast?.currently?.temperature)!)
                    
                case .failure(let error):
                    // there was an error
                    print("\(error)")
                    return
                }
            })
        }
        
        else {
            self.client.getForecast(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!, time: date, completion: { result in
                switch result {
                case .success(let currentForecast, _):
                    // we got the current forecast
                    print("\(String(describing: currentForecast.currently?.icon?.rawValue))")
                    self.forecast = currentForecast
                    self.currentWeather = (self.forecast?.currently?.icon).map { $0.rawValue }
                    self.currentTemperature = Int((self.forecast?.currently?.temperature)!)
                    
                case .failure(let error):
                    // there was an error
                    print("\(error)")
                    return
                }
            })
        }
        

    }
    
    func chooseAlarmBasedOnWeather() -> String { // return a string for the url of the sound clip based on the current weather condition
        
        if isDelegateSet {
            
            if currentWeather == "clear-day" || currentWeather == "clear-night" || currentWeather == "partly-cloudy-day" || currentWeather == "partly-cloudy-night" {
                
                return "Vivaldi - The_Four_Seasons - Spring_Mvt_1_Allegro-(clear)"
            }
            else if currentWeather == "cloudy" || currentWeather == "fog" {
                
                return "Vivaldi - The_Four_Seasons - Winter_Mvt_3_Allegro-(clouds)"
            }
            else if currentWeather == "rain"{
                
                return "Vivaldi - The_Four_Seasons - Spring_Mvt_2_Largo-(rain)"
            }
            else if currentWeather == "thunderstorm" || currentWeather == "tornado" || currentWeather == "hail" {
                
                return "Vivaldi - The_Four_Seasons - Summer_Mvt_3-(storm)"
            }
            else if currentWeather == "snow" || currentWeather == "sleet" {
                
                return "Vivaldi - The_Four_Seasons - Winter_Mvt_1-(snow)"
            }
            else if currentWeather == "windy" {
                
                return "Wagner - The_Ride_Of_The_Valkyries-(wind)"
            }
        }

        return ""
    }
    
    func delegateIsSet() -> Bool {
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self as? CLLocationManagerDelegate
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            print("location = \(String(describing: self.locationManager.location))")
            
            getWeatherInfo(date: Date(), isDataBlock: true)
            
            return true
        }
        return false
    }
    
    func getNextSunriseTime() -> Int{
        
        if isDelegateSet {
            
            if let absoluteSunriseTime = self.forecast?.daily?.data[1].sunriseTime {
                
                let currentDate = Date()
                let cal = Calendar(identifier: .gregorian)
                let tomorrowMidnight = cal.startOfDay(for: currentDate.addingTimeInterval(86400))
                
                var startTimeSeconds = Int(absoluteSunriseTime.timeIntervalSince(tomorrowMidnight))
                
                if startTimeSeconds % 60 != 0 {
                    let remainder = startTimeSeconds % 60
                    startTimeSeconds -= remainder
                }
                return startTimeSeconds
            
            }
            
        }
        return 0
        
    }
    
    func isHeavyPrecipitationAtTime(timeRemaining: Int) -> Bool{
        
        if isDelegateSet {
            
            let currentDate = Date()
            let alarmDate = Date(timeInterval: TimeInterval(timeRemaining), since: currentDate)
            getWeatherInfo(date: alarmDate, isDataBlock: false)
            
            if (forecast?.currently?.precipitationIntensity)! > 0.3  { // indicates that there will be more than 0.3 inches of water per hour at that time (what is considered heavy precipitation)
                
                return true
            }
            
        }
        return false
    }

}

// MARK: Extensions
// -----------------
extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}
