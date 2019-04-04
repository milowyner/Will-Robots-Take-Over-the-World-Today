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
import Hero
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    // Background views
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var topBackground: UIImageView!
    @IBOutlet weak var centeredBackground: UIImageView!
    @IBOutlet weak var bottomBackground: UIImageView!
    @IBOutlet weak var fullscreenBackground: UIImageView!
    
    // Outlets for setting animations
    @IBOutlet var backgroundViews: [UIImageView]!
    @IBOutlet weak var mainContentView: UIView!
    
    // Weather labels
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var apparentTemperatureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var nearestStormLabel: UILabel!
    
    // Static title labels
    @IBOutlet var titleLabels: [UILabel]!
    
    // Buttons
    @IBOutlet weak var unitToggle: UIButton!
    @IBOutlet weak var takeOverButtonView: UIStackView!
    @IBOutlet weak var takeOverLabel: UILabel!
    @IBOutlet weak var aboutButton: UIButton!
    
    // Swipe gesture recognizers
    @IBOutlet var swipeUp: UISwipeGestureRecognizer!
    @IBOutlet var swipeLeft: UISwipeGestureRecognizer!
    
    // Width constraints for centeredBackground view
    @IBOutlet weak var proportionalCenteredBackgroundConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullWidthCenteredBackgroundConstraint: NSLayoutConstraint!
    
    // Core Location manager for getting device location
    let locationManager = CLLocationManager()
    
    // Network manager for checking if network is connected/disconnected
    let networkManager = NetworkReachabilityManager(host: "api.darksky.net")
    
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
    
    // Interval determining often location/weather requests are called
    var updateInterval: TimeInterval = 300
    
    // Date object used for limiting how often location/weather requests are called
    lazy var lastDate = Date(timeInterval: -updateInterval, since: Date())
    
    // Loading screen view controller
    lazy var loadingScreen = storyboard?.instantiateViewController(withIdentifier: "loadingScreen") as! LoadingViewController

    // Flag to keep track of the first time viewDidAppear is called
    var firstTimeViewDidAppear = true
    
    //
    // MARK: View Did Load
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set fonts
        summaryLabel.setDynamicCustomFont(for: .body)
        temperatureLabel.setDynamicCustomFont(for: .title1)
        takeOverLabel.setDynamicCustomFont(for: .subheadline)
        
        for label in titleLabels {
            label.setDynamicCustomFont(for: .subheadline)
        }
        
        for label in [apparentTemperatureLabel, windSpeedLabel, nearestStormLabel] {
            label!.setDynamicCustomFont(for: .title3)
        }
        
        // Set up animations
        self.hero.isEnabled = true
        aboutButton.hero.id = "about"
        takeOverButtonView.hero.id = "takeOver"
        gradientView.hero.id = "gradient"
        
        // Listen for network changes
        networkManager?.listener = { status in
            // If network is reachable
            if status != .notReachable {
                // Get current location
                self.enableBasicLocationServices()
            }
        }
        networkManager?.startListening()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstTimeViewDidAppear {
            // Show loading screen
            present(loadingScreen, animated: false, completion: nil)
            firstTimeViewDidAppear = false
        }
    }
    
    
    //
    // MARK: IBActions
    //
    
    // Change weatherData temperature unit
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
    
    // Unwind to weather view controller
    @IBAction func unwindToWeather(_ sender: UIStoryboardSegue) {
    }
    
    //
    // MARK: Location Services
    //
    
    func enableBasicLocationServices() {
        locationManager.delegate = self
        
        // Only update location and request weather data every 5 minutes
        if -lastDate.timeIntervalSinceNow >= updateInterval {
            
            // Set last date to current date
            lastDate = Date()
            
            // Check authorization status
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
            @unknown default:
                fatalError()
            }
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
        @unknown default:
            fatalError()
        }
    }
    
    // Location was updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        print("Location successful")
        
        // Update coordinates
        coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        // Print city, state, country to console for debugging
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location,
            completionHandler: { (placemarks, error) in
                if error == nil {
                    if let firstLocation = placemarks?[0] {
                        let locationString = "\(firstLocation.locality ?? ""), \(firstLocation.administrativeArea ?? "")".uppercased()
                        print(locationString)
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
                
                // Hide loading screen
                self.loadingScreen.dismiss(animated: true, completion: nil)
                
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
            temperatureLabel.fadeOut()
            temperatureLabel.text = "\(Int(temperature.rounded()))º"
            temperatureLabel.fadeIn()
        }
        
        if let summary = weatherData.summary {
            summaryLabel.text = summary.uppercased()
        }
        
        if let apparentTemperature = weatherData.apparentTemperature {
            apparentTemperatureLabel.fadeOut()
            apparentTemperatureLabel.text = "\(Int(apparentTemperature.rounded()))º"
            apparentTemperatureLabel.fadeIn()

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
                .font: UIFont.dynamicCustomFont(for: .body),
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
            unitToggle.titleLabel?.adjustsFontForContentSizeCategory = true
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
            centeredBackground.contentMode = .scaleAspectFit
            
            // Unhide take over button
            takeOverButtonView.isHidden = false
            
            // Enable swipe gestures
            swipeUp.isEnabled = true
            swipeLeft.isEnabled = true
            
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
    // MARK: Segues
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set background fade animation
        for fadingView in backgroundViews {
            fadingView.hero.modifiers = [.fade, .useGlobalCoordinateSpace]
        }
        
        // If going to RobotViewController
        if let destination = segue.destination as? RobotViewController {
            // Set answer
            let answer = Answer(icon: weatherData.icon!, moonPhase: weatherData.moonPhase!)
            destination.willRobotsTakeOver = answer
            
            // Set animations
            mainContentView.hero.modifiers = [
                .translate(CGPoint(x: 0, y: -view.bounds.height)),
                .useGlobalCoordinateSpace]
        }
        
        // If going to AboutViewController
        if segue.destination is AboutViewController {
            // Set animations
            mainContentView.hero.modifiers = [
                .translate(CGPoint(x: -view.bounds.width, y: 0)),
                .useGlobalCoordinateSpace]
        }
    }
}

