//
//  AppDelegate.swift
//  BuildTracker
//
//  Created by Ricardo Pereira on 14/12/2018.
//  Copyright © 2018 Whitesmith. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: BuildsViewController())
        window?.makeKeyAndVisible()
        return true
    }

}
