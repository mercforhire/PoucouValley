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
    
    override func setupTheme() {
        super.setupTheme()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "HomeExploreViewController")
        let child2: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "HomeShopViewController")
        let child3: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "HomeSearchViewController")
        return [child1, child2, child3]
    }

}

