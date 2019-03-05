//
//  RobotViewController.swift
//  Will Robots Take Over the World?
//
//  Created by Milo Wyner on 3/4/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit

class RobotViewController: UIViewController {

    @IBOutlet weak var robotIcon: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var willRobotsTakeOver: Answer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let answer = willRobotsTakeOver else {
            fatalError("RobotViewController should have been sent an Answer")
        }
        
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
