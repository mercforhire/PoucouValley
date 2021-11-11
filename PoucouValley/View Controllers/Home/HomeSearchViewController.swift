//
//  HomeSearchViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-07.
//

import UIKit
import XLPagerTabStrip

class HomeSearchViewController: BaseViewController {
    private var itemInfo = IndicatorInfo(title: "Search")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension HomeSearchViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
