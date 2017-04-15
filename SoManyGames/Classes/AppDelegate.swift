//
//  AppDelegate.swift
//  SoManyGames
//
//  Created by Luke Charman on 18/03/2017.
//  Copyright © 2017 Luke Charman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? {
        didSet {
            if let image = UIImage(named: "Tile") {
                window?.backgroundColor = UIColor(patternImage: image)
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        let size = UIScreen.main.bounds.size

        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        } else if max(size.width, size.height) > 700 {
            return .all
        } else {
            return .portrait
        }
    }

}

