//
//  AppDelegate.swift
//  Drip
//
//  Created by Muukii on 2022/01/04.
//

import UIKit
import DripCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    let newWindow = UIWindow()
    newWindow.tintColor = .secondaryLabel
    newWindow.rootViewController = StartupViewController()
    newWindow.makeKeyAndVisible()
    self.window = newWindow

    return true
  }

}

