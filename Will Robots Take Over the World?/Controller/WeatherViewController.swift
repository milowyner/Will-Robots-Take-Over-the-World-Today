//
//  ViewController.swift
//  Will Robots Take Over the World?
//
//  Created by Milo Wyner on 2/24/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var apparentTemperatureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var nearestStormLabel: UILabel!
    
    let locationManager = CLLocationManager()

    // Light and dark colors used for background gradient
    var lightColor = UIColor(named: "clearDayLight")!
    var darkColor = UIColor(named: "clearDayDark")!
    
    // Location
    var coordinates = "" {
        didSet {
            requestWeatherData()
        }
    }
    
    // Dark Sky API Key
    var apiKey = "5fd28bb80945cf58fd60c4c8a3acb413"
    
    // Dark Sky URL
    var url: String {
        return "https://api.darksky.net/forecast/\(apiKey)/\(coordinates)?units=auto&exclude=minutely,hourly,daily,alerts"
    }
    
    // Weather data
    var weatherData = WeatherData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        // Set colors for gradient view
        gradientView.firstColor = lightColor
        gradientView.secondColor = darkColor
        
        // Get current location
        enableBasicLocationServices()
    }
    
    // MARK: Location Services
    
    func enableBasicLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            // Disable location features
            print("location initially denied")
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            locationManager.startUpdatingLocation()
            print("location initially authorized")
        }
    }
    
    // MARK: Core Location Delegate Methods
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            print("location denied after changing auth status")
            
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            print("location authorized after changing auth status")
            
        case .notDetermined, .authorizedAlways:
            print("location auth status not determined")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        print("location successful")
        locationManager.stopUpdatingLocation()
        
        // Update coordinates
        coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        // Print city, state, country to console for debugging
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location,
            completionHandler: { (placemarks, error) in
                if error == nil {
                    if let firstLocation = placemarks?[0] {
                        print("\(firstLocation.locality ?? ""), \(firstLocation.administrativeArea ?? ""), \(firstLocation.country ?? "")")
                    }
                }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Could not get location")
        print(error)
    }

    
    // MARK: Networking
    
    func requestWeatherData() {
        Alamofire.request(url).responseJSON { response in
            if let jsonResult = response.result.value {
                let json = JSON(jsonResult)
                
                self.storeWeatherData(from: json)
                
                self.updateUIWithWeatherData()
                
            } else {
                print(response.error!)
            }
        }
    }
    
    // MARK: JSON Parsing
    
    func storeWeatherData(from json: JSON) {
        let current = json["currently"]
//        let units = json["flags"]["units"]
        
        weatherData.summary = current["summary"].stringValue
        weatherData.temperature = current["temperature"].double
        weatherData.windSpeed = current["windSpeed"].double
        weatherData.apparentTemperature = current["apparentTemperature"].double
        weatherData.nearestStorm = current["nearestStormDistance"].double
        
        //print(current["city"].stringValue)
        print(weatherData)
    }
    
    // MARK: Update UI
    
    func updateUIWithWeatherData() {
        if let temperature = weatherData.temperature {
            temperatureLabel.text = "\(Int(temperature.rounded()))º"
        }
        
        if let summary = weatherData.summary {
            summaryLabel.text = summary.uppercased()
        }
        
        if let apparentTemperature = weatherData.apparentTemperature {
            apparentTemperatureLabel.text = "\(Int(apparentTemperature.rounded()))º"
        }
        
        if let windSpeed = weatherData.windSpeed {
            let unit = "mph"
            windSpeedLabel.text = "\(Int(windSpeed.rounded())) \(unit)"
        }
        
        if let nearestStorm = weatherData.nearestStorm {
            let unit = "mi"
            nearestStormLabel.text = "\(Int(nearestStorm.rounded())) \(unit)"
        }
        
    }
    
}

