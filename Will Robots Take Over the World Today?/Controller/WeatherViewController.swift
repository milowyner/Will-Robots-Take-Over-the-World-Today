//
//  ViewController.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 2/24/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    // Background views
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var topBackground: UIImageView!
    @IBOutlet weak var centeredBackground: UIImageView!
    @IBOutlet weak var bottomBackground: UIImageView!
    @IBOutlet weak var fullscreenBackground: UIImageView!
    
    // Weather labels
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var apparentTemperatureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var nearestStormLabel: UILabel!
    
    // Buttons
    @IBOutlet weak var unitToggle: UIButton!
    @IBOutlet weak var takeOverButtonView: UIStackView!
    @IBOutlet weak var aboutButton: UIButton!
    
    // Width constraints for centeredBackground view
    @IBOutlet weak var proportionalCenteredBackgroundConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullWidthCenteredBackgroundConstraint: NSLayoutConstraint!
    
    // Core Location manager for getting device location
    let locationManager = CLLocationManager()
    
    // Network manager for checking if network is connected/disconnected
    let manager = NetworkReachabilityManager(host: "api.darksky.net")
    
    // Currnet device coordinates
    var coordinates = "" {
        didSet {
            requestWeatherData()
        }
    }
    
    // Dark Sky API Key
    var apiKey = "5fd28bb80945cf58fd60c4c8a3acb413"
    
    // Dark Sky URL
    var url: String {
        return "https://api.darksky.net/forecast/\(apiKey)/\(coordinates)?units=auto&exclude=minutely,hourly,alerts"
    }
    
    // Weather data model
    var weatherData = WeatherData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear background
        topBackground.image = nil
        centeredBackground.image = nil
        
        // Get current location
        enableBasicLocationServices()
        
        // Enable location services when network is reachable
        manager?.listener = { status in
            if status != .notReachable {
                self.enableBasicLocationServices()
            }
        }
        manager?.startListening()
    }
    
    @IBAction func unitTogglePressed(_ sender: UIButton) {
        if let temperatureUnit = weatherData.temperatureUnit {
            switch temperatureUnit {
            case .fahrenheit:
                weatherData.temperatureUnit = .celcius
            case .celcius:
                weatherData.temperatureUnit = .fahrenheit
            }
            updateUIWithWeatherData()
        }
    }
    
    @IBAction func unwindToWeather(_ sender: UIStoryboardSegue) {

    }
    //
    // MARK: Location Services
    //
    
    func enableBasicLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            // Disable location features
            print("Location denied")
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            locationManager.startUpdatingLocation()
            print("Location authorized")
        }
    }
    
    //
    // MARK: Core Location Delegate Methods
    //
    
    // Changed auth status
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            print("Location denied after changing auth status")
            
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            print("Location authorized after changing auth status")
            
        case .notDetermined, .authorizedAlways:
            print("Location auth status not determined")
        }
    }
    
    // Location was updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        locationManager.stopUpdatingLocation()
        
        print("Location successful")
        
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
    
    // Failed to get location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Could not get location, \(error)")
    }

    //
    // MARK: Networking
    //
    
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
    
    //
    // MARK: JSON Parsing
    //
    
    func storeWeatherData(from json: JSON) {
        let current = json["currently"]
        let units = json["flags"]["units"].stringValue
        
        // Set temperature unit
        switch units {
        case "us": weatherData.temperatureUnit = .fahrenheit
        case "si", "ca", "uk2": weatherData.temperatureUnit = .celcius
        default: print("Error, unknown units")
        }
        // Set speed unit
        switch units {
        case "us", "uk2": weatherData.speedUnit = .milesPerHour
        case "si": weatherData.speedUnit = .metersPerSecond
        case "ca": weatherData.speedUnit = .kilometersPerHour
        default: print("Error, unkown units")
        }
        // Set distance unit
        switch units {
        case "us", "uk2": weatherData.distanceUnit = .miles
        case "si", "ca": weatherData.distanceUnit = .kilometers
        default: print("Error, unkown units")
        }
        
        // Set weather data
        weatherData.summary = current["summary"].string
        weatherData.icon = current["icon"].string
        weatherData.temperature = current["temperature"].double
        weatherData.windSpeed = current["windSpeed"].double
        weatherData.apparentTemperature = current["apparentTemperature"].double
        weatherData.nearestStorm = current["nearestStormDistance"].double
        weatherData.moonPhase = json["daily"]["data"][0]["moonPhase"].double
    }
    
    //
    // MARK: Update UI
    //
    
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
            var unit: String? = nil
            if let speedUnit = weatherData.speedUnit {
                switch speedUnit {
                case .milesPerHour:
                    unit = " mph"
                case .kilometersPerHour:
                    unit = " kph"
                case .metersPerSecond:
                    unit = " m/s"
                }
            }
            windSpeedLabel.text = "\(Int(windSpeed.rounded()))\(unit ?? "")"
        }
        
        if let nearestStorm = weatherData.nearestStorm {
            var unit: String? = nil
            if let distanceUnit = weatherData.distanceUnit {
                switch distanceUnit {
                case .kilometers:
                    unit = " km"
                case .miles:
                    unit = " mi"
                }
            }
            nearestStormLabel.text = "\(Int(nearestStorm.rounded()))\(unit ?? "")"
        }
        
        if let temperatureUnit = weatherData.temperatureUnit {
            let attributedString = NSMutableAttributedString(string: "Cº/ Fº", attributes: [
                .font: UIFont(name: "Cabin-Regular", size: 14.0)!,
                .foregroundColor: UIColor(named: "whiteSubtle")!,
                .kern: 0.84
                ])
            
            switch temperatureUnit {
            case .fahrenheit:
                attributedString.addAttributes([
                    .foregroundColor: UIColor.white
                    ], range: NSRange(location: 4, length: 2))
            case .celcius:
                attributedString.addAttributes([
                    .foregroundColor: UIColor.white
                    ], range: NSRange(location: 0, length: 2))
            }
            
            unitToggle.setAttributedTitle(attributedString, for: .normal)
        }
        
        if let icon = weatherData.icon {
            // Clear background images
            topBackground.image = nil
            centeredBackground.image = nil
            bottomBackground.image = nil
            fullscreenBackground.image = nil
            
            // Reset constraints
            fullWidthCenteredBackgroundConstraint.isActive = false
            proportionalCenteredBackgroundConstraint.isActive = true
            centeredBackground.contentMode = .scaleAspectFill
            
            // Unhide take over button
            takeOverButtonView.isHidden = false
            
            // Set background based on weather icon
            switch icon {
            case "clear-day":
                gradientView.firstColor = UIColor(named: "dayLight")
                gradientView.secondColor = UIColor(named: "dayDark")
                bottomBackground.image = UIImage(named: "bg-clear")
            case "clear-night":
                gradientView.firstColor = UIColor(named: "nightLight")
                gradientView.secondColor = UIColor(named: "nightDark")
                bottomBackground.image = UIImage(named: "bg-clear")
            case "wind":
                gradientView.firstColor = UIColor(named: "dayLight")
                gradientView.secondColor = UIColor(named: "dayDark")
                centeredBackground.image = UIImage(named: "bg-wind")
                proportionalCenteredBackgroundConstraint.isActive = false
                fullWidthCenteredBackgroundConstraint.isActive = true
            case "fog":
                gradientView.firstColor = UIColor(named: "neutralLight")
                gradientView.secondColor = UIColor(named: "neutralDark")
                fullscreenBackground.image = UIImage(named: "bg-fog")
            case "partly-cloudy-day":
                gradientView.firstColor = UIColor(named: "dayLight")
                gradientView.secondColor = UIColor(named: "cloudyDark")
                topBackground.image = UIImage(named: "bg-partly-cloudy")
            case "partly-cloudy-night":
                gradientView.firstColor = UIColor(named: "nightLight")
                gradientView.secondColor = UIColor(named: "nightDark")
                topBackground.image = UIImage(named: "bg-partly-cloudy")
            case "tornado":
                gradientView.firstColor = UIColor(named: "neutralLight")
                gradientView.secondColor = UIColor(named: "neutralDark")
                fullscreenBackground.image = UIImage(named: "bg-tornado")
            default:
                // Cloudy, rain, snow, sleet, hail, thunderstorm
                gradientView.firstColor = UIColor(named: "cloudyLight")
                gradientView.secondColor = UIColor(named: "cloudyDark")
                topBackground.image = UIImage(named: "bg-clouds")
                
                if icon == "rain" {
                    centeredBackground.image = UIImage(named: "bg-rain")
                } else if icon == "snow" {
                    centeredBackground.image = UIImage(named: "bg-snow")
                } else if icon == "sleet" {
                    centeredBackground.image = UIImage(named: "bg-sleet")
                } else if icon == "hail" {
                    centeredBackground.image = UIImage(named: "bg-hail")
                } else if icon == "thunderstorm" {
                    centeredBackground.image = UIImage(named: "bg-lightning")
                    centeredBackground.contentMode = .scaleAspectFill
                    proportionalCenteredBackgroundConstraint.isActive = false
                    fullWidthCenteredBackgroundConstraint.isActive = true
                }
            }
        }
    }
    
    //
    // MARK: Segue
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToRobotViewController" {
            let destination = segue.destination as! RobotViewController
            let answer = Answer(icon: weatherData.icon!, moonPhase: weatherData.moonPhase!)
            
            destination.willRobotsTakeOver = answer
        }
    }
}
