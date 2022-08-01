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
    
    @IBOutlet weak var searchBar: UISearchBar!
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
            fetchContent()
        }
    }
    
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
        
        let topDownContentInset: CGFloat = 15
        let leftRightContentInset: CGFloat = 15
        let itemSpace: CGFloat = 19
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
                if response.success, let data = response.data {
                    self.merchants = Array(data)
                    complete?(true)
                } else {
                    showErrorDialog(error: response.message)
                    complete?(false)
                }
                complete?(true)
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
        
        api.searchShops(keyword: query) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    self.searchResults = Array(data)
                } else {
                    showErrorDialog(error: response.message)
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }
}

extension HomeShopViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BusinessCategories.list().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! ImageAndLabelNormalCell
        cell.roundCorners(style: .medium)
        cell.config(data: BusinessCategories.list()[indexPath.row])
        if category == BusinessCategories.list()[indexPath.row] {
            cell.highlight()
        } else {
            cell.unhighlight()
        }
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

extension HomeShopViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.scrollToTop(animated: false)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.trim().isEmpty {
            delayTimer.textDidGetEntered(text: "")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        delayTimer.textDidGetEntered(text: "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let text = searchBar.text, !text.trim().isEmpty else {
            tableView.scrollToTop(animated: false)
            delayTimer.textDidGetEntered(text: "")
            return
        }
        
        delayTimer.textDidGetEntered(text: text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text, text.trim().isEmpty {
            delayTimer.textDidGetEntered(text: "")
        }
    }
}

extension HomeShopViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        let text: String = text.trim()
        
        if text.count <= 3 {
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
