//
//  HomeExploreViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-07.
//

import UIKit
import CollectionViewWaterfallLayout
import XLPagerTabStrip

class HomeExploreViewController: BaseViewController {
    private var itemInfo = IndicatorInfo(title: "Explore")
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var plans: [Plan]? {
        didSet {
            plansCellSizes.removeAll()
            for _ in 0...(plans?.count ?? 0) {
                plansCellSizes.append(generateRandomSize())
            }
            collectionView.reloadData()
        }
    }
    
    private var searchResults: [Plan]? {
        didSet {
            searchResultsCellSizes.removeAll()
            for _ in 0...(searchResults?.count ?? 0) {
                searchResultsCellSizes.append(generateRandomSize())
            }
            collectionView.reloadData()
        }
    }
    
    private var plansCellSizes: [CGSize] = []
    private var searchResultsCellSizes: [CGSize] = []
    
    private var delayTimer = DelayedSearchTimer()
    private var storiesCollectionReusableView: StoriesCollectionReusableView?
    
    private var searchMode: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerHeight = 130
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(UINib(nibName: "StoriesCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withReuseIdentifier: "Header")
        
        delayTimer.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    private func fetchContent(complete: ((Bool) -> Void)? = nil) {
        api.fetchPlans { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    self.plans = Array(data)
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
    
    private func generateRandomSize() -> CGSize {
        let width: Double = Double(collectionView.frame.width) - 10 * 3
        let random = Double(arc4random_uniform((UInt32(width * 1.5))))
        let randomSize = CGSize(width: width, height: width + random)
        return randomSize
    }
    
    private func requestToSearch(query: String?) {
        guard let query = query, !query.isEmpty else {
            self.searchResults = nil
            return
        }
        
        api.searchPlans(keyword: query) { [weak self] result in
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

extension HomeExploreViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        collectionView.scrollToTop(animated: false)
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
            collectionView.scrollToTop(animated: false)
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

extension HomeExploreViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension HomeExploreViewController: DelayedSearchTimerDelegate {
    func shouldSearch(text: String) {
        let text: String = text.trim()
        
        if text.count <= 3 {
            searchMode = false
            searchResults = nil
        } else {
            searchMode = true
            
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeExploreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "Header",
                                                                         for: indexPath) as! StoriesCollectionReusableView
        
        self.storiesCollectionReusableView = headerView
        headerView.searchBar.delegate = self
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
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
