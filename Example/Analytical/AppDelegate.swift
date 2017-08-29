//
//  AppDelegate.swift
//  Analytical
//
//  Created by Dal Rupnik on 07/19/2016.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        analytics.setup(with: application, launchOptions: launchOptions)
        
        print("Device identifier: \(analytics.deviceId)")
        
        analytics.identify(userId: analytics.deviceId)
        
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { success, error in
            
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        analytics.activate()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Token: \(deviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error registering: \(error.localizedDescription)")
    }
}
