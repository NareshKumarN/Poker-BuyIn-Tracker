//
//  AppDelegate.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR  6/30/25.
//
//

import UIKit

// MARK: - AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
//        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = AdvancedLaunchScreenViewController()
        window?.makeKeyAndVisible()
        // Have to Add Google.PLIST file
        //FirebaseApp.configure()
        return true
    }
}
