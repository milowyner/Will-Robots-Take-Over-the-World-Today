//
//  LoadingViewController.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 3/13/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit
import Hero

class LoadingViewController: UIViewController {
    
    // Keeps track of whether there is an error
    var errorMessageReceieved = false
    // Keeps track of whether the view has appeared
    var viewDidAppear = false
    
    var mainErrorMessage: String = "" {
        didSet {
            errorMessageReceieved = true
            
            // Only show the error message if the view has appeared
            if viewDidAppear {
                showErrorMessage()
            }
        }
    }
    
    var secondaryErrorMessage: String = ""
    
    @IBOutlet weak var radarImage: UIImageView!
    @IBOutlet weak var robotImage: UIImageView!
    @IBOutlet weak var errorMessageView: UIView!
    @IBOutlet weak var topErrorMessageLabel: UILabel!
    @IBOutlet weak var bottomErrorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        
        // Set up custom fonts
        topErrorMessageLabel.setDynamicCustomFont(for: .body)
        bottomErrorMessageLabel.setDynamicCustomFont(for: .body)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppear = true
        
        if errorMessageReceieved { // Show error if there is one
            showErrorMessage()
        } else { // Show loading radar icon instead
            
            // Set up rotation animation
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = 2 * Double.pi
            rotation.duration = 2
            rotation.repeatCount = Float.infinity
            
            // Wait a couple seconds before showing the loading icon
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // An error message could have been recieved during the waiting period, so only show
                // the loading icon if there is no error message
                if !self.errorMessageReceieved {
                    UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn, animations: {
                        self.radarImage.alpha = 0.5
                    }, completion: nil)
                    
                    self.radarImage.layer.add(rotation, forKey: "Spin")
                }
            }
        }
    }
    
    // Hides loading icon if there is one, and shows error message and robot icon.
    func showErrorMessage() {
        // Set error text
        topErrorMessageLabel.text = mainErrorMessage
        bottomErrorMessageLabel.text = secondaryErrorMessage
        
        // Hide radar image
        radarImage.alpha = 0
        
        // Fade in the robot image and error message
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseIn, animations: {
            self.robotImage.alpha = 1
            self.errorMessageView.alpha = 1
        }, completion: nil)
    }

}
