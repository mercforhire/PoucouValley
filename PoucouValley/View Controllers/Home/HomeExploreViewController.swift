//
//  HomeExploreViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-07.
//

import UIKit
import CollectionViewWaterfallLayout
import XLPagerTabStrip
import CRRefresh

class HomeExploreViewController: BaseViewController {
    private var itemInfo = IndicatorInfo(title: "Explore")
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var plans: [Plan]? {
        didSet {
            plansCellSizes.removeAll()
            for _ in 0...(plans?.count ?? 0) {
                plansCellSizes.append(generateRandomSize(collectionView: collectionView))
            }
            collectionView.reloadData()
        }
    }
    
    private var searchResults: [Plan]? {
        didSet {
            searchResultsCellSizes.removeAll()
            for _ in 0...(searchResults?.count ?? 0) {
                searchResultsCellSizes.append(generateRandomSize(collectionView: collectionView))
            }
            collectionView.reloadData()
        }
    }
    
    private var plansCellSizes: [CGSize] = []
    private var searchResultsCellSizes: [CGSize] = []
    
    private var delayTimer = DelayedSearchTimer()
    private var headerView: SearchBarCollectionHeaderView? {
        didSet {
            guard let headerView = headerView else { return }
            
            headerView.searchBar.delegate = self
        }
    }
    
    private var searchMode: Bool = false {
        didSet {
            if oldValue != searchMode {
                collectionView.reloadData()
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerHeight = 1
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(UINib(nibName: "SearchBarCollectionHeaderView", bundle: nil), forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withReuseIdentifier: "Header")
        
        delayTimer.searchDelay = 2.0
        delayTimer.delegate = self
        
        collectionView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            guard let self = self else { return }
            
            if self.searchMode {
                self.requestToSearch(query: self.headerView?.searchBar.text)
            } else {
                self.fetchContent()
            }
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    private func fetchContent(complete: ((Bool) -> Void)? = nil) {
        plans == nil ? FullScreenSpinner().show() : nil
        
        api.fetchPlans { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            self.collectionView.cr.endHeaderRefresh()
            
            switch result {
            case .success(let response):
                if response.success {
                    self.plans = Array(response.data)
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
        
        api.searchPlans(keyword: query) { [weak self] result in
            guard let self = self else { return }

            self.collectionView.cr.endHeaderRefresh()
            
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
}

extension HomeExploreViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        collectionView.scrollToTop(animated: false)
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

extension HomeExploreViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension HomeExploreViewController: DelayedSearchTimerDelegate {
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

// MARK: - UICollectionViewDataSource
extension HomeExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "Header",
                                                                         for: indexPath) as! SearchBarCollectionHeaderView
        
        self.headerView = headerView
        headerView.searchBar.delegate = self
        return headerView
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchMode {
            return searchResults?.count ?? 0
        } else {
            return plans?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowCollectionViewCell", for: indexPath) as? FollowCollectionViewCell else { return UICollectionViewCell() }
        
        if searchMode {
            guard let plan = searchResults?[indexPath.row] else {
                return cell
            }
            cell.config(plan: plan)
            return cell
        } else {
            guard let plan = plans?[indexPath.row] else {
                return cell
            }
            cell.config(plan: plan)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> Float {
        guard let headerView = headerView else { return 1 }
        
        // Use this view to calculate the optimal size based on the collection view's width
        let size = headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                      withHorizontalFittingPriority: .required, // Width is fixed
                                                      verticalFittingPriority: .fittingSizeLevel) // Height can be as large as needed
        return Float(size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let plan = plans?[indexPath.row] else { return }
        
        openPlanDetailsVC(plan: plan)
    }
}


// MARK: - CollectionViewWaterfallLayoutDelegate
extension HomeExploreViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if searchMode {
            return searchResultsCellSizes[indexPath.item]
        } else {
            return plansCellSizes[indexPath.item]
        }
    }
}
