//
//  BaseTabBarViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-27.
//

import UIKit

class BaseTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    var api: PoucouAPI {
        return PoucouAPI.shared
    }
    var userManager: UserManager {
        return UserManager.shared
    }
    var appSettings: AppSettingsManager {
        return AppSettingsManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            handleRefreshForTabBar()
        }
    }
    
    func handleRefreshForTabBar() {
        DispatchQueue.main.async {
            guard let themeData = ThemeManager.shared.themeData else { return }
            
            self.tabBar.barStyle = ThemeManager.shared.barStyle
            self.tabBar.tintColor = themeData.darkerGreen.hexColor
            self.tabBar.barTintColor = themeData.whiteBackground.hexColor
            self.tabBar.unselectedItemTintColor = themeData.tabBarTheme.unSelectedColor.hexColor
            self.tabBar.backgroundColor = themeData.whiteBackground.hexColor
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController,
            let _ = navController.viewControllers.first as? CardViewController {
            navigationController?.navigationBar.isHidden = true
        } else {
            navigationController?.navigationBar.isHidden = false
        }
    }
}
