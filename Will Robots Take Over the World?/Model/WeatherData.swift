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
    enum SpeedUnit {
        case milesPerHour
        case kilometersPerHour
        case metersPerSecond
    }
    enum DistanceUnit {
        case miles
        case kilometers
    }
    
    // Temperature unit; calculates/sets correct temperatures when set
    var temperatureUnit: TemperatureUnit? {
        didSet {
            if let oldTemperature = temperature, let oldApparentTemperature = apparentTemperature, temperatureUnit != oldValue {
                // Convert temperatures to new unit
                switch temperatureUnit! {
                case .fahrenheit:
                    temperature = oldTemperature * 9/5 + 32
                    apparentTemperature = oldApparentTemperature * 9/5 + 32
                case .celcius:
                    temperature = (oldTemperature - 32) * 5/9
                    apparentTemperature = (oldApparentTemperature - 32) * 5/9
                }
            }
        }
    }
    
    var speedUnit: SpeedUnit?
    var distanceUnit: DistanceUnit?
    
    var temperature: Double?
    var apparentTemperature: Double?
    var summary: String?
    var icon: String?
    var windSpeed: Double?
    var nearestStorm: Double?
}
