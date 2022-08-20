//
//  BaseButtonBarPagerTabStripViewController.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-12.
//

import Foundation
import XLPagerTabStrip

class BaseButtonBarPagerTabStripViewController: ButtonBarPagerTabStripViewController {
    private var observer: NSObjectProtocol?
    
    func setup() {
        // override
        setupTheme()
    }
    
    func setupTheme() {
        if navigationController?.isNavigationBarHidden == false {
            navigationController?.isNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = false
        }
        
        view.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        containerView.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        
        settings.style.buttonBarBackgroundColor = themeManager.themeData!.whiteBackground.hexColor
        settings.style.buttonBarItemBackgroundColor = themeManager.themeData!.whiteBackground.hexColor
        settings.style.selectedBarBackgroundColor = themeManager.themeData!.whiteBackground.hexColor
        settings.style.buttonBarItemTitleColor = themeManager.themeData!.textLabel.hexColor
        buttonBarView.backgroundColor = themeManager.themeData!.whiteBackground.hexColor
        buttonBarView.reloadData()
        
        if observer == nil {
            observer = NotificationCenter.default.addObserver(forName: ThemeManager.Notifications.ThemeChanged,
                                                              object: nil,
                                                              queue: OperationQueue.main) { [weak self] (notif) in
                self?.setupTheme()
            }
        }
    }
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarItemFont = UIFont(name: "Poppins-Regular", size: 18.0)!
        settings.style.selectedBarHeight = 0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 10
        settings.style.buttonBarRightContentInset = 10
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = .lightGray
            newCell?.label.textColor = .black
        }
        delegate = self
        
        setup()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
}
