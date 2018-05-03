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
    let client = DarkSkyClient(apiKey: "327180fccdc777b85e2b1fdbb6adab37") // creates a client to use with the api
    let locationManager = CLLocationManager()
    
    var forecast: Forecast?
    var currentWeather: String?
    var isDelegateSet: Bool!
    var sunriseTime: Int?
    
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
    func getWeatherInfo(date: Date) {
        // Once the user's location is known, the api will check for current weather condition at that location

        if isDelegateSet {
            client.getForecast(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, time: date, completion: { result in
                switch result {
                case .success(let currentForecast, _):
                    // we got the current forecast
                    print("\(String(describing: currentForecast.currently?.summary))")
                    self.forecast = currentForecast
                    
                case .failure(let error):
                    // there was an error
                    print("\(error)")
                    return
                }
            })
        }

    }
    
    func chooseAlarm() {
        
        if currentWeather == "clear-day" || currentWeather == "clear-night" || currentWeather == "partly-cloudy-day" || currentWeather == "partly-cloudy-night" {
            
        }
        else if currentWeather == "cloudy" || currentWeather == "fog" {
            
        }
        else if currentWeather == "rain" || currentWeather == "thunderstorm" || currentWeather == "tornado" || currentWeather == "hail"{
            
        }
        else if currentWeather == "snow" || currentWeather == "sleet" {
            
        }
        else if currentWeather == "windy" {
            
        }
        
    }
    
    func delegateIsSet() -> Bool {
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self as? CLLocationManagerDelegate
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            print("location = \(String(describing: self.locationManager.location))")
            
            return true
        }
        return false
    }
    
    func getSunriseTomorrow() -> Int{
        
        if isDelegateSet {
            
            let tomorrowDate = Date().tomorrow
            getWeatherInfo(date: tomorrowDate)
            
            let absoluteSunriseTime = self.forecast?.currently?.sunriseTime
            return Int(Date().timeIntervalSince(absoluteSunriseTime!)) // returns the time until sunrise tomorrow
            
        }
        return 0
        
    }
    
    func getPrecipitation() {
        
        if isDelegateSet {
            
        }
        
    }

}

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
