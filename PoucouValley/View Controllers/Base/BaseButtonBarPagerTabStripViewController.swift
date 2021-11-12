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
        if navigationController?.navigationBar.isHidden == false {
            navigationController?.isNavigationBarHidden = true
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .white
        settings.style.buttonBarItemFont = UIFont(name: "Poppins-Regular", size: 18.0)!
        settings.style.selectedBarHeight = 0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 10
        settings.style.buttonBarRightContentInset = 10

        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = .lightGray
            newCell?.label.textColor = .black
        }
        delegate = self
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setup()
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
