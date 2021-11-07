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
        case Follow
        case Explore
        case ClickMe
    }
    
    @IBOutlet var dummyButton: UIBarButtonItem!
    @IBOutlet var filterButton: UIBarButtonItem!
    
    override func setupTheme() {
        super.setupTheme()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerForPushNotifications()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "FollowViewController")
        let child2: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "ExploreViewController")
        let child3: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "ClickMeViewController")
        let child4: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "GuestScheduleViewController")
        return [child1, child2, child3, child4]
    }

}

