//
//  AppDelegate.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR  6/30/25.
//
//

import UIKit
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let tab = UITabBarController()
        tab.viewControllers = [
            UINavigationController(rootViewController: CurrentSessionViewController()),
            UINavigationController(rootViewController: UsersViewController()),
            UINavigationController(rootViewController: SessionsViewController())
        ]
        tab.viewControllers?[0].tabBarItem = UITabBarItem(title: "Current", image: UIImage(systemName: "gamecontroller.fill"), tag: 0)
        tab.viewControllers?[1].tabBarItem = UITabBarItem(title: "Players", image: UIImage(systemName: "person.3.fill"), tag: 1)
        tab.viewControllers?[2].tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "clock.fill"), tag: 2)

        tab.tabBar.tintColor = .systemBlue
        tab.tabBar.backgroundColor = .systemBackground

        window?.rootViewController = tab
        window?.makeKeyAndVisible()
        // Have to Add Google.PLIST file
        //FirebaseApp.configure()
        return true
    }
}
