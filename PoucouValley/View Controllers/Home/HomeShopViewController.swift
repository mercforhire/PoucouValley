//
//  HomeShopViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-07.
//

import UIKit
import XLPagerTabStrip
import CRRefresh

class HomeShopViewController: BaseViewController {
    private var itemInfo = IndicatorInfo(title: "Shops")
    
    @IBOutlet weak var searchBar: ThemeSearchBar!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    private var delayTimer = DelayedSearchTimer()
    
    private var merchants: [Merchant]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var searchResults: [Merchant]? {
        didSet {
            tableView.reloadData()
        }
    }
    private var searchMode: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    private var category: BusinessCategories?  {
        didSet {
            categoryCollectionView.reloadData()
            fetchContent()
        }
    }
    private var clickedMerchant: Merchant?
    
    override func setup() {
        super.setup()
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            guard let self = self else { return }
            
            if self.searchMode {
                self.requestToSearch(query: self.searchBar.text)
            } else {
                self.fetchContent()
            }
        }
        
        delayTimer.searchDelay = 2.0
        delayTimer.delegate = self
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.defaultBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topDownContentInset: CGFloat = 5
        let leftRightContentInset: CGFloat = 5
        let itemSpace: CGFloat = 5
        let itemsPerRow: CGFloat = 4
        let itemsPerColumn: CGFloat = 2
        let flowlayout = UICollectionViewFlowLayout()
        let cellWidth: CGFloat = (categoryCollectionView.frame.width - leftRightContentInset * 2 - (itemsPerRow - 1) * itemSpace) / itemsPerRow
        let cellHeight: CGFloat = (categoryCollectionView.frame.height - topDownContentInset * 2 - (itemsPerColumn - 1) * itemSpace) / itemsPerColumn
        flowlayout.itemSize = .init(width: cellWidth, height: cellHeight)
        flowlayout.scrollDirection = .horizontal
        flowlayout.sectionInset = .init(top: topDownContentInset, left: leftRightContentInset, bottom: topDownContentInset, right: leftRightContentInset)
        flowlayout.minimumLineSpacing = itemSpace
        flowlayout.minimumInteritemSpacing = itemSpace
        categoryCollectionView.setCollectionViewLayout(flowlayout, animated: false)
    }

    private func fetchContent(complete: ((Bool) -> Void)? = nil) {
        merchants == nil ? FullScreenSpinner().show() : nil
        
        api.fetchShops(category: category) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            self.tableView.cr.endHeaderRefresh()
            
            switch result {
            case .success(let response):
                if response.success {
                    self.merchants = Array(response.data)
                    complete?(true)
                } else {
                    showErrorDialog(error: response.message)
                    complete?(false)
                }
            case .failure:
                showNetworkErrorDialog()
                complete?(false)
            }
        }
    }
    
    private func requestToSearch(query: String?) {
        guard let query = query, !query.isEmpty else {
            self.searchResults = nil
            return
        }
        
        api.searchShops(keyword: query, category: category) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                if response.success {
                    self.searchResults = Array(response.data)
                } else {
                    showErrorDialog(error: response.message)
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShopDetailsViewController, let clickedMerchant = clickedMerchant {
            vc.merchant = clickedMerchant
        }
    }
}

extension HomeShopViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BusinessCategories.list().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! ImageAndLabelNormalCell
        cell.config(data: BusinessCategories.list()[indexPath.row])
        if category == BusinessCategories.list()[indexPath.row] {
            cell.highlight()
        } else {
            cell.unhighlight()
        }
        cell.contentView.roundCorners(style: .medium)
        cell.addShadow(style: .medium)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if category == BusinessCategories.list()[indexPath.row] {
            category = nil
        } else {
            category = BusinessCategories.list()[indexPath.row]
        }
    }
}

extension HomeShopViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchMode {
            return max(1, searchResults?.count ?? 0)
        } else {
            return max(1, merchants?.count ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchMode {
            if (searchResults?.count ?? 0) == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoResultsCell", for: indexPath)
                return cell
            }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantTableViewCell", for: indexPath) as? MerchantTableViewCell else {
                return MerchantTableViewCell()
            }
            let merchant = searchResults![indexPath.row]
            cell.config(merchant: merchant)
            return cell
        } else {
            if (merchants?.count ?? 0) == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoShopsCell", for: indexPath)
                return cell
            }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantTableViewCell", for: indexPath) as? MerchantTableViewCell else {
                return MerchantTableViewCell()
            }
            let merchant = merchants![indexPath.row]
            cell.config(merchant: merchant)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchMode {
            if (searchResults?.count ?? 0) == 0 {
                return
            }
            let merchant = searchResults![indexPath.row]
            clickedMerchant = merchant
            performSegue(withIdentifier: "goToMerchant", sender: self)
        } else {
            if (merchants?.count ?? 0) == 0 {
                return
            }
            let merchant = merchants![indexPath.row]
            clickedMerchant = merchant
            performSegue(withIdentifier: "goToMerchant", sender: self)
        }
    }
}

extension HomeShopViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.scrollToTop(animated: false)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delayTimer.textDidGetEntered(text: searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        delayTimer.textDidGetEntered(text: "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delayTimer.textDidGetEntered(text: searchBar.text ?? "")
    }
}

extension HomeShopViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        let text: String = text.trim()
        
        if text.count < 3 {
            searchMode = false
            searchResults = nil
        } else {
            searchMode = true
            requestToSearch(query: text)
        }
    }
}

extension HomeShopViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

