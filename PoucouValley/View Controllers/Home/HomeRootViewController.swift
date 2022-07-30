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
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    private let stackViewDefaultHeight: CGFloat = 44.0
    private var stackViewVisible = true {
        didSet {
            if stackViewVisible {
                self.stackViewHeight.constant = self.stackViewDefaultHeight
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    
                })
            } else {
                self.stackViewHeight.constant = 0.0
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    
                })
            }
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @objc func showTopBar(_ notification: Notification) {
        stackViewVisible = true
    }
    
    @objc func hideTopBar(_ notification: Notification) {
        stackViewVisible = false
    }
    
    // MARK: - PagerTabStripDataSource

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child1: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "HomeExploreViewController")
        let child2: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "HomeShopViewController")
        let child3: UIViewController! = StoryboardManager.loadViewController(storyboard: "Home", viewControllerId: "HomeFollowingViewController")
        return [child1, child2, child3]
    }

}

