//
//  AboutViewController.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 3/7/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit
import Hero

class AboutViewController: UIViewController {

    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var fullScreenBackground: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var mainContentView: UIView!

    @IBOutlet var headlineLabels: [UILabel]!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var mainTextButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up fonts
        for label in headlineLabels {
            label.setDynamicCustomFont(for: .subheadline)
        }
        
        mainTextLabel.setDynamicCustomFont(for: .title3)
        mainTextButton.titleLabel!.font = UIFont.dynamicCustomFont(for: .title3)
        privacyPolicyButton.titleLabel!.font = UIFont.dynamicCustomFont(for: .caption1)
        
        // Set up animations
        self.hero.isEnabled = true
        aboutButton.hero.id = "about"
        gradientView.hero.id = "gradient"
        mainContentView.hero.modifiers = [
            .translate(CGPoint(x: view.bounds.width, y: 0)),
            .useGlobalCoordinateSpace
        ]
        fullScreenBackground.hero.modifiers = [
            .fade,
            .useGlobalCoordinateSpace
        ]
    }
    

    @IBAction func darkSkyButtonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://darksky.net/poweredby/")!)
    }
    
    
    @IBAction func privacyPolicyButtonPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://willrobotstakeovertheworld.today/privacy-policy/")!)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
