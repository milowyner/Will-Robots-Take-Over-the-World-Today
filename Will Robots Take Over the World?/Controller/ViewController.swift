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
    
    // Light and dark colors used for background gradient
    var lightColor = UIColor(named: "clearDayLight")!
    var darkColor = UIColor(named: "clearDayDark")!
    
    // Dark Sky URL
    let url = "https://api.darksky.net/forecast/5fd28bb80945cf58fd60c4c8a3acb413/37.8267,-122.4233?exclude=minutely,hourly,daily,alerts,flags"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set colors for gradient view
        gradientView.firstColor = lightColor
        gradientView.secondColor = darkColor
        
        // Networking
        
        Alamofire.request(url).responseJSON { response in
            if let jsonResult = response.result.value {
                print("JSON: \(jsonResult)") // serialized json response
                
                let json = JSON(jsonResult)
                print("SwiftyJSON: \(json)")

                let temperature = json["currently"]["temperature"].double
                print(temperature!)
                
            } else {
                print(response.error!)
            }
        }
    }


}

