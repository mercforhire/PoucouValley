//
//  HomeShopViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-07.
//

import UIKit
import XLPagerTabStrip

class HomeShopViewController: BaseViewController {
    
    private var itemInfo = IndicatorInfo(title: "Shops")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension HomeShopViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
