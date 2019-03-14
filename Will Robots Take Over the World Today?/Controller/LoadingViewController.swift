//
//  LoadingViewController.swift
//  Will Robots Take Over the World Today?
//
//  Created by Milo Wyner on 3/13/19.
//  Copyright © 2019 Milo Wyner. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var radarImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 2
        rotation.repeatCount = Float.infinity
        radarImage.layer.add(rotation, forKey: "Spin")
    }

}
