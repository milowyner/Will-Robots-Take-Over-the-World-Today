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

class ViewController: UIViewController {
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var apparentTemperatureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var nearestStormLabel: UILabel!
    
    // Light and dark colors used for background gradient
    var lightColor = UIColor(named: "clearDayLight")!
    var darkColor = UIColor(named: "clearDayDark")!
    
    // Dark Sky URL
    let url = "https://api.darksky.net/forecast/5fd28bb80945cf58fd60c4c8a3acb413/37.8267,-122.4233?units=auto&exclude=minutely,hourly,daily,alerts"
    
    // Weather data
    var weatherData = WeatherData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set colors for gradient view
        gradientView.firstColor = lightColor
        gradientView.secondColor = darkColor
        
        // Networking
        requestWeatherData()
        
    }
    
    func requestWeatherData() {
        Alamofire.request(url).responseJSON { response in
            if let jsonResult = response.result.value {
                let json = JSON(jsonResult)
                print("JSON: \(json)")
                
                self.storeWeatherData(from: json)
                
                self.updateUIWithWeatherData()
                
            } else {
                print(response.error!)
            }
        }
    }
    
    func storeWeatherData(from json: JSON) {
        let current = json["currently"]
        let units = json["flags"]["units"]
        print("UNITS: \(units)")
        
        weatherData.temperature = current["temperature"].double
        weatherData.summary = current["summary"].stringValue
        
        print(weatherData)
    }
    
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
        
    }

}

