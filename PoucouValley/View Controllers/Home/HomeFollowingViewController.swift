//
//  HomeSearchViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-07.
//

import UIKit
import XLPagerTabStrip

class HomeFollowingViewController: BaseViewController {
    private var itemInfo = IndicatorInfo(title: "Following")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension HomeFollowingViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
