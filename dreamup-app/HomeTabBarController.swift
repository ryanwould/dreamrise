//
//  HomeTabBarController.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 4/23/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        self.tabBar.backgroundImage = UIImage.imageWithColor(tintColor: UIColor.clear)
    }
}

extension UIImage {
    static func imageWithColor(tintColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        tintColor.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
