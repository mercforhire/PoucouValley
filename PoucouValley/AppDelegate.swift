//
//  AppDelegate.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-06.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        IQKeyboardManager.shared.enable = true
        initRealm()
        return true
    }
    
    private func initRealm() {
        PoucouAPI.shared.initRealm { success in
            if !success {
                self.showRetryConnectRealm()
            } else {
//                StoryboardManager.load(storyboard: "Login")
            }
        }
    }
    
    private func showRetryConnectRealm() {
        DispatchQueue.main.async {
            guard let topVC = UIViewController.topViewController else { return }
            
            let alert = UIAlertController(title: "Fatal error", message: "Fatal error: Failed to connect to Realm server.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                self.initRealm()
            }))
            topVC.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

