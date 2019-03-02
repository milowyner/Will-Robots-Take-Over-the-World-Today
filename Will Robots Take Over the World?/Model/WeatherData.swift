//
//  WeatherData.swift
//  Will Robots Take Over the World?
//
//  Created by Milo Wyner on 3/1/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import Foundation

struct WeatherData {
    enum TemperatureUnit {
        case celcius
        case fahrenheit
    }
    var unit: TemperatureUnit = .fahrenheit {
        didSet {
            // Convert temperatures to new unit
        }
    }
    
    var temperature: Double?
    var apparentTemperature: Double?
    var summary: String?
    var windSpeed: Double?
    var nearestStorm: Double?
}
