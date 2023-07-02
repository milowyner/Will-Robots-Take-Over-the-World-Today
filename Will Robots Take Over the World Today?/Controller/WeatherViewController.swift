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
import WeatherKit

fileprivate extension String {
    static let temperatureUnitKey = "temperatureUnit"
}

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
    var coordinates = ""
    
    // Dark Sky API Key
    var apiKey = "5fd28bb80945cf58fd60c4c8a3acb413"
    
    // Dark Sky URL
    var url: String {
        return "https://api.darksky.net/forecast/\(apiKey)/\(coordinates)?units=auto&exclude=minutely,hourly,alerts"
    }
    
    // Weather data model
    var weather: Weather?
    
    // Temperature unit, mapped to UserDefaults using celsius = 0 and fahrenheit = 1
    var temperatureUnit: UnitTemperature = {
        if let rawValue = UserDefaults.standard.value(forKey: .temperatureUnitKey) as? Int {
            return rawValue == 0 ? .celsius : .fahrenheit
        } else {
            return UnitTemperature(forLocale: Locale.current)
        }
    }() {
        didSet {
            let rawValue = temperatureUnit == .celsius ? 0 : 1
            UserDefaults.standard.set(rawValue, forKey: .temperatureUnitKey)
        }
    }
    
    // Checks if it's day or night
    var daytime: Bool {
        if let sunEvents = weather?.dailyForecast.first?.sun,
           let sunrise = sunEvents.sunrise,
           let sunset = sunEvents.sunset {
            return (sunrise..<sunset).contains(Date())
        } else {
            return true
        }
    }
    
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
        summaryLabel.setDynamicCustomFont(for: .headline)
        temperatureLabel.setDynamicCustomFont(for: .title1)
        takeOverLabel.setDynamicCustomFont(for: .headline)
        
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
    
    // Change the temperature unit
    @IBAction func unitTogglePressed(_ sender: UIButton) {
        temperatureUnit = temperatureUnit == .celsius ? .fahrenheit : .celsius
        updateUIWithWeatherData()
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
            switch CLLocationManager().authorizationStatus {
            case .notDetermined:
                // Request when-in-use authorization initially
                locationManager.requestWhenInUseAuthorization()
                
            case .restricted, .denied:
                // Disable location features
                locationDenied()
                
            case .authorizedWhenInUse, .authorizedAlways:
                // Enable location features
                locationManager.startUpdatingLocation()
                print("Location authorized")
            @unknown default:
                fatalError()
            }
        }
    }
    
    // Location was denied
    func locationDenied() {
        print("Location denied")
        loadingScreen.mainErrorMessage = "Unable to retrieve your location. This likely means robots are already taking over the world. Run!"
        loadingScreen.secondaryErrorMessage = "(Or…you simply need to allow location sharing in your device’s settings.)"
    }
    
    //
    // MARK: Core Location Delegate Methods
    //
    
    // Changed auth status
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            locationDenied()
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            print("Location authorized after changing auth status")
            
        case .notDetermined:
            print("Location auth status not determined")
        @unknown default:
            fatalError()
        }
    }
    
    // Location was updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location successful")
        
        let location = locations.last!
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        // Update coordinates
        coordinates = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        requestWeatherData(location: location)
    }
    
    // Failed to get location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location")
        loadingScreen.mainErrorMessage = "Unable to retrieve your location. This likely means robots are already taking over the world. Run!"
    }

    //
    // MARK: Networking
    //
    
    func requestWeatherData(location: CLLocation) {
        Task.init {
            do {
                weather = try await WeatherService.shared.weather(for: location)
                print("Weather retrieved successfully")
                
                updateUIWithWeatherData()
                loadingScreen.dismiss(animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
    }
    
    //
    // MARK: Update UI
    //
    
    func updateUIWithWeatherData() {
        guard let weather else { return }
        let currentWeather = weather.currentWeather
        
        // Unhide main content view
        mainContentView.isHidden = false
        
        let temperature = currentWeather.temperature.converted(to: temperatureUnit)
        temperatureLabel.fadeOut()
        temperatureLabel.text = "\(Int(temperature.value.rounded()))º"
        temperatureLabel.fadeIn()
        
        let summary = "\(currentWeather.condition)"
        summaryLabel.text = summary.uppercased()
        
        let apparentTemperature = currentWeather.apparentTemperature.converted(to: temperatureUnit)
        apparentTemperatureLabel.fadeOut()
        apparentTemperatureLabel.text = "\(Int(apparentTemperature.value.rounded()))º"
        apparentTemperatureLabel.fadeIn()
        
        let windSpeed = currentWeather.wind.speed
        windSpeedLabel.text = windSpeed.formatted(.measurement(
            width: .abbreviated,
            numberFormatStyle: .number.rounded(increment: 1))
        )
                
        // Temperature unit label
        let attributedString = NSMutableAttributedString(string: "Cº/ Fº", attributes: [
            .font: UIFont.dynamicCustomFont(for: .headline),
            .foregroundColor: UIColor(named: "whiteSubtle")!,
            .kern: 0.84
        ])
        switch temperatureUnit {
        case .fahrenheit:
            attributedString.addAttributes([
                .foregroundColor: UIColor.white
            ], range: NSRange(location: 4, length: 2))
        case .celsius:
            attributedString.addAttributes([
                .foregroundColor: UIColor.white
            ], range: NSRange(location: 0, length: 2))
        default:
            break
        }
        unitToggle.setAttributedTitle(attributedString, for: .normal)
        unitToggle.titleLabel?.adjustsFontForContentSizeCategory = true
        
        // Clear background images
        topBackground.image = nil
        centeredBackground.image = nil
        bottomBackground.image = nil
        fullscreenBackground.image = nil
        
        // Reset constraints
        fullWidthCenteredBackgroundConstraint.isActive = false
        proportionalCenteredBackgroundConstraint.isActive = true
        centeredBackground.contentMode = .scaleAspectFit
        
        // Enable swipe gestures
        swipeUp.isEnabled = true
        swipeLeft.isEnabled = true
        
        // Set background based on weather condition
        switch currentWeather.condition {
        case .clear, .hot:
            if daytime {
                gradientView.firstColor = UIColor(named: "dayLight")
                gradientView.secondColor = UIColor(named: "dayDark")
                bottomBackground.image = UIImage(named: "bg-clear")
            } else {
                gradientView.firstColor = UIColor(named: "nightLight")
                gradientView.secondColor = UIColor(named: "nightDark")
                bottomBackground.image = UIImage(named: "bg-clear")
            }
        case .windy, .breezy, .blowingDust:
            gradientView.firstColor = UIColor(named: "dayLight")
            gradientView.secondColor = UIColor(named: "dayDark")
            centeredBackground.image = UIImage(named: "bg-wind")
            proportionalCenteredBackgroundConstraint.isActive = false
            fullWidthCenteredBackgroundConstraint.isActive = true
        case .foggy, .haze, .smoky, .frigid:
            gradientView.firstColor = UIColor(named: "neutralLight")
            gradientView.secondColor = UIColor(named: "neutralDark")
            fullscreenBackground.image = UIImage(named: "bg-fog")
        case .partlyCloudy, .mostlyClear:
            if daytime {
                gradientView.firstColor = UIColor(named: "dayLight")
                gradientView.secondColor = UIColor(named: "cloudyDark")
                topBackground.image = UIImage(named: "bg-partly-cloudy")
            } else {
                gradientView.firstColor = UIColor(named: "nightLight")
                gradientView.secondColor = UIColor(named: "nightDark")
                topBackground.image = UIImage(named: "bg-partly-cloudy")
            }
        case .tropicalStorm, .hurricane:
            gradientView.firstColor = UIColor(named: "neutralLight")
            gradientView.secondColor = UIColor(named: "neutralDark")
            fullscreenBackground.image = UIImage(named: "bg-tornado")
        default:
            // Cloudy, rain, snow, sleet, hail, thunderstorm
            gradientView.firstColor = UIColor(named: "cloudyLight")
            gradientView.secondColor = UIColor(named: "cloudyDark")
            topBackground.image = UIImage(named: "bg-clouds")
            
            switch currentWeather.condition {
            case .rain, .heavyRain, .sunShowers, .drizzle, .freezingDrizzle:
                centeredBackground.image = UIImage(named: "bg-rain")
            case .snow, .heavySnow, .flurries, .sunFlurries, .blowingSnow, .blizzard:
                centeredBackground.image = UIImage(named: "bg-snow")
            case .sleet, .wintryMix:
                centeredBackground.image = UIImage(named: "bg-sleet")
            case .hail, .freezingRain:
                centeredBackground.image = UIImage(named: "bg-hail")
            case .thunderstorms, .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms:
                centeredBackground.image = UIImage(named: "bg-lightning")
                centeredBackground.contentMode = .scaleAspectFill
                proportionalCenteredBackgroundConstraint.isActive = false
                fullWidthCenteredBackgroundConstraint.isActive = true
            default:
                break
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
            
            let answer = Answer(weather: weather, daytime: daytime)
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

