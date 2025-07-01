//
//  AppDelegate.swift
//  PokerBuyin
//
//  Created by Naresh Kumar Nagulavancha on 6/30/25.
//
//
//import UIKit
//// MARK: – App Delegate & Tab Bar
//
//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    var window: UIWindow?
//
//    func application(
//      _ application: UIApplication,
//      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//        window = UIWindow(frame: UIScreen.main.bounds)
//        let tab = UITabBarController()
//        tab.viewControllers = [
//            UINavigationController(rootViewController: UsersViewController()),
//            UINavigationController(rootViewController: SessionsViewController())
//        ]
//        tab.viewControllers?[0].tabBarItem = UITabBarItem(title: "Users", image: UIImage(systemName: "person.3"), tag: 0)
//        tab.viewControllers?[1].tabBarItem = UITabBarItem(title: "Sessions", image: UIImage(systemName: "clock"), tag: 1)
//        window?.rootViewController = tab
//        window?.makeKeyAndVisible()
//        return true
//    }
//}
