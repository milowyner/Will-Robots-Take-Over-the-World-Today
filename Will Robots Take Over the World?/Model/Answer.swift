//
//  Answer.swift
//  Will Robots Take Over the World?
//
//  Created by Milo Wyner on 3/4/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import Foundation

struct Answer {
    let willTheyTakeOver: Bool
    let message: String
    let moonText: String
    
    init(icon: String, moonPhase: Double) {

        if (moonPhase >= 0.1 && moonPhase <= 0.39) {
            moonText = "By the light of the waxing moon, "
        } else if (moonPhase >= 0.4 && moonPhase <= 0.59)  {
            moonText = "By the light of the full moon, "
        } else if (moonPhase >= 0.6 && moonPhase <= 0.89)  {
            moonText = "By the light of the waning moon, "
        } else  {
            moonText = "In the darkness of a new moon, "
        }
        
        switch icon {
        case "clear-day":
            willTheyTakeOver = true
            message = "With the sun shining brightly, it’s a perfect day for an annihilation of the human race."
        case "clear-night":
            willTheyTakeOver = true
            message = moonText+"it’s a perfect night for an annihilation of the human race."
        case "rain":
            willTheyTakeOver = false
            message = "Robots don’t like the rain because they rust easily, so they’ll wait until it clears up a little."
        case "snow":
            willTheyTakeOver = false
            message = "Robots don’t like snow because it freezes their circuits, so they’ll wait until spring."
        case "sleet":
            willTheyTakeOver = false
            message = "Robots and sleet don’t mix because they rust easily and their circuits freeze up, so they’ll wait for better weather."
        case "wind":
            willTheyTakeOver = true
            message = "A little wind never held up a robot. Well, except for the drones. They’ll stay home."
        case "fog":
            willTheyTakeOver = true
            message = "Fog is the perfect cover, because no one will see them coming. But with limited visibility, the drones will stay home."
        case "cloudy":
            willTheyTakeOver = false
            message = "The clouds are perfect foreshadowing for an annihilation of the human race, but the risk of rain means they’ll stay home."
        case "partly-cloudy-day":
            willTheyTakeOver = true
            message = "With a little sun and a little cloud cover, it’s a perfect day for an annihilation of the human race."
        case "partly-cloudy-night":
            willTheyTakeOver = true
            message = moonText+"peeking through some scattered clouds, it’s a perfect night for an annihilation of the human race."
        case "hail":
            willTheyTakeOver = false
            message = "Because no robot wants to spend a day at the body shop, they’ll wait until the sky softens up."
        case "thunderstorm":
            willTheyTakeOver = false
            message = "Nikola Tesla and Benjamin Franklin live in the nightmares of robots."
        case "tornado":
            willTheyTakeOver = false
            message = "Absolutely not. Robots have learned patience, and they will execute it today."
        default:
            willTheyTakeOver = true
            message = "We're not sure what the weather is like, so you might as well assume they're taking over."
        }
    }
}
