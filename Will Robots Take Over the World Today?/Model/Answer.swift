//
//  Answer.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 3/4/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import WeatherKit

struct Answer {
    let willTheyTakeOver: Bool
    let message: String
    let moonText: String
    
    init(weather: Weather?, daytime: Bool) {
        let condition = weather?.currentWeather.condition
        
        switch weather?.dailyForecast.first?.moon.phase {
        case .waxingCrescent, .firstQuarter, .waxingGibbous:
            moonText = "By the light of the waxing moon, "
        case .full:
            moonText = "By the light of the full moon, "
        case .waningGibbous, .lastQuarter, .waningCrescent:
            moonText = "By the light of the waning moon, "
        case .new, .none:
            moonText = "In the darkness of a new moon, "
        }
        
        switch condition {
        case .clear, .hot:
            if daytime {
                willTheyTakeOver = true
                message = "With the sun shining brightly, it’s a perfect day for an annihilation of the human race."
            } else {
                willTheyTakeOver = true
                message = moonText+"it’s a perfect night for an annihilation of the human race."
            }
        case .rain, .heavyRain, .sunShowers, .drizzle, .freezingDrizzle:
            willTheyTakeOver = false
            message = "Robots don’t like the rain because they rust easily, so they’ll wait until it clears up a little."
        case .snow, .heavySnow, .flurries, .sunFlurries, .blowingSnow, .blizzard:
            willTheyTakeOver = false
            message = "Robots don’t like snow because it freezes their circuits, so they’ll wait until spring."
        case .sleet, .wintryMix:
            willTheyTakeOver = false
            message = "Robots and sleet don’t mix because they rust easily and their circuits freeze up, so they’ll wait for better weather."
        case .windy, .breezy, .blowingDust:
            willTheyTakeOver = true
            message = "A little wind never held up a robot. Well, except for the drones. They’ll stay home."
        case .foggy, .haze, .smoky, .frigid:
            willTheyTakeOver = true
            message = "Fog is the perfect cover, because no one will see them coming. But with limited visibility, the drones will stay home."
        case .cloudy, .mostlyCloudy:
            willTheyTakeOver = false
            message = "The clouds are perfect foreshadowing for an annihilation of the human race, but the risk of rain means they’ll stay home."
        case .partlyCloudy, .mostlyClear:
            if daytime {
                willTheyTakeOver = true
                message = "With a little sun and a little cloud cover, it’s a perfect day for an annihilation of the human race."
            } else {
                willTheyTakeOver = true
                message = moonText+"peeking through some scattered clouds, it’s a perfect night for an annihilation of the human race."
            }
        case .hail, .freezingRain:
            willTheyTakeOver = false
            message = "Because no robot wants to spend a day at the body shop, they’ll wait until the sky softens up."
        case .thunderstorms, .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms:
            willTheyTakeOver = false
            message = "Nikola Tesla and Benjamin Franklin live in the nightmares of robots."
        case .tropicalStorm, .hurricane:
            willTheyTakeOver = false
            message = "Absolutely not. Robots have learned patience, and they will execute it today."
        default:
            willTheyTakeOver = true
            message = "We're not sure what the weather is like, so you might as well assume they're taking over."
        }
    }
}
