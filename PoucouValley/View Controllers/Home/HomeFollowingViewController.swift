//
//  HomeSearchViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-07.
//

import UIKit
import XLPagerTabStrip
import CRRefresh

class HomeFollowingViewController: BaseViewController {
    private var itemInfo = IndicatorInfo(title: "Following")
    
    @IBOutlet weak var tableView: UITableView!
    
    private var merchants: [Merchant]? {
        didSet {
            tableView.reloadData()
        }
    }
    private var clickedMerchant: Merchant?
    
    override func setupTheme() {
        super.setupTheme()
    }
    
    override func setup() {
        super.setup()
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func loadData() {
        merchants == nil ? FullScreenSpinner().show() : nil
        
        api.fetchFollowedShops() { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            self.tableView.cr.endHeaderRefresh()
            
            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    let merchants = Array(data)
                    self.merchants = merchants
                } else {
                    showErrorDialog(error: response.message)
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }
}

extension HomeFollowingViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension HomeFollowingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, merchants?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (merchants?.count ?? 0) == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantTableViewCell", for: indexPath) as? MerchantTableViewCell else {
            return MerchantTableViewCell()
        }
        let merchant = merchants![indexPath.row]
        cell.config(merchant: merchant)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (merchants?.count ?? 0) == 0 {
            return
        }
        let merchant = merchants![indexPath.row]
        clickedMerchant = merchant
        performSegue(withIdentifier: "goToMerchant", sender: self)
    }
}
