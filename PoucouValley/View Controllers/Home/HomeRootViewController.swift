//
//  HomeViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-06.
//

import UIKit
import XLPagerTabStrip
import UserNotifications

class HomeRootViewController: BaseButtonBarPagerTabStripViewController {
    enum Tabs: Int {
        case Explore
        case Shop
        case Search
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "HomeExploreViewController")
        let child2: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "HomeShopViewController")
        let child3: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "HomeFollowingViewController")
        return [child1, child2, child3]
    }
}

