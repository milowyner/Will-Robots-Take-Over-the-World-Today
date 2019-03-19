//
//  RobotViewController.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 3/4/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit
import Hero

class RobotViewController: UIViewController {

    @IBOutlet weak var robotIcon: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var takeOverButtonView: UIStackView!
    @IBOutlet weak var takeOverLabel: UILabel!
    
    // Outlets for animation
    @IBOutlet weak var robotView: UIView!
    @IBOutlet var slidingViews: [UIView]!
    
    var willRobotsTakeOver: Answer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set fonts
        answerLabel.setDynamicCustomFont(for: .title1)
        messageLabel.setDynamicCustomFont(for: .body)
        takeOverLabel.setDynamicCustomFont(for: .body)
        
        // Set up animations
        self.hero.isEnabled = true
        takeOverButtonView.hero.id = "takeOver"
        for slidingView in slidingViews {
            slidingView.hero.modifiers = [
                .translate(CGPoint(x: 0, y: view.bounds.height)),
                .useGlobalCoordinateSpace]
        }
        
        // Get answer
        guard let answer = willRobotsTakeOver else {
            fatalError("RobotViewController should have been sent an Answer")
        }
        
        // Set background and text based on answer
        if answer.willTheyTakeOver == true {
            answerLabel.text = "YES"
            view.backgroundColor = UIColor(named: "threatYes")
            robotIcon.image = UIImage(named: "icon-robot-answer-yes")
        } else {
            answerLabel.text = "NO"
            view.backgroundColor = UIColor(named: "threatNo")
            robotIcon.image = UIImage(named: "icon-robot-answer-no")
        }
        messageLabel.text = answer.message
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
