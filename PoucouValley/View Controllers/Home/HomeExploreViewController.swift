//
//  HomeExploreViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-07.
//

import UIKit
import CollectionViewWaterfallLayout
import XLPagerTabStrip

protocol HomeExploreViewControllerDelegate: class {
    func updateSearchBarText(text: String)
}

class HomeExploreViewController: BaseViewController {
    private var itemInfo = IndicatorInfo(title: "Explore")
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchVCContainer: UIView!
    
    private var history: [String] = []
    private var stories: [UnsplashPhoto]?
    private var content: [UnsplashPhoto]? {
        didSet {
            for _ in 0...(content?.count ?? 0) {
                cellSizes.append(generateRandomSize())
            }
        }
    }
    private let cellWidth: CGFloat = 80.0
    private lazy var paginationManager: VerticalPaginationManager = {
        let manager = VerticalPaginationManager(scrollView: collectionView)
        manager.delegate = self
        return manager
    }()
    private var cellSizes: [CGSize] = []
    private var pagesLoaded = 0
    private var delayTimer = DelayedSearchTimer()
    private var homeSearchViewController: HomeSearchViewController!
    
    weak var delegate: HomeSearchViewControllerDelegate?
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = .init(width: cellWidth, height: storiesCollectionView.frame.height - 20)
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = 0
        flowlayout.minimumInteritemSpacing = 0
        flowlayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        storiesCollectionView.setCollectionViewLayout(flowlayout, animated: false)
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerHeight = 0
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        
        paginationManager.refreshViewColor = .clear
        paginationManager.loaderColor = .darkGray
        
        searchBar.backgroundImage = UIImage()
        
        delayTimer.delegate = self
        
        for child in children {
            if let childVC = child as? HomeSearchViewController {
                self.homeSearchViewController = childVC
                delegate = childVC
                self.homeSearchViewController.delegate = self
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchContent()
        
        history = AppSettingsManager.shared.getSearchHistory()
        homeSearchViewController.historySearches = history
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func fetchContent(complete: ((Bool) -> Void)? = nil) {
        api.getStories { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.stories = response
                self.storiesCollectionView.reloadData()
                complete?(true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                complete?(false)
            }
        }
        
        api.getPhotos(page: pagesLoaded + 1) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.content = response
                self.pagesLoaded = self.pagesLoaded + 1
                self.collectionView.reloadData()
                complete?(true)
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
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
}

extension HomeExploreViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        NotificationCenter.default.post(name: Notifications.HomeScreenHideTopBar, object: nil)
        searchVCContainer.isHidden = false
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
        NotificationCenter.default.post(name: Notifications.HomeScreenShowTopBar, object: nil)
        searchVCContainer.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let text = searchBar.text, !text.trim().isEmpty else {
            NotificationCenter.default.post(name: Notifications.HomeScreenHideTopBar, object: nil)
            searchVCContainer.isHidden = false
            delayTimer.textDidGetEntered(text: "")
            return
        }
        
        delayTimer.textDidGetEntered(text: text)
        
        if !history.contains(text.trim()) {
            history.append(text.trim())
            let maxCount = 10
            if history.count > maxCount {
                history = Array(history[(history.count - 1 - maxCount)...(history.count - 1)])
            }
            AppSettingsManager.shared.setSearchHistory(searchHistory: history)
            homeSearchViewController.historySearches = history
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
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
            delegate?.requestToSearch(query: nil)
        } else {
            delegate?.requestToSearch(query: text)
        }
    }
}

extension HomeExploreViewController: HomeExploreViewControllerDelegate {
    func updateSearchBarText(text: String) {
        searchBar.text = text
    }
}
// MARK: - UICollectionViewDataSource
extension HomeExploreViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.storiesCollectionView {
            return stories?.count ?? 0
        }
        else if collectionView == self.collectionView {
            return content?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.storiesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as? StoryCollectionViewCell,
                    let story = stories?[indexPath.row] else { return UICollectionViewCell() }
            
            cell.config(unsplashPhoto: story)
            return cell
        } else if collectionView == self.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowCollectionViewCell", for: indexPath) as? FollowCollectionViewCell, let content = content?[indexPath.row] else { return UICollectionViewCell() }
            
            cell.config(unsplashPhoto: content)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}


// MARK: - CollectionViewWaterfallLayoutDelegate
extension HomeExploreViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionView == self.collectionView {
            return cellSizes[indexPath.item]
        }
        
        return CGSize(width: cellWidth, height: storiesCollectionView.frame.height)
    }
}

extension HomeExploreViewController: VerticalPaginationManagerDelegate {
    
    func delay(_ delay: Double, closure: @escaping () -> Void) {
        let deadline = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(
            deadline: deadline,
            execute: closure
        )
    }
    
    func loadMore(completion: @escaping (Bool) -> Void) {
        delay(0.5) { [weak self] in
            guard let self = self else { return }
            
            self.api.getPhotos(page: self.pagesLoaded + 1) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.content?.append(contentsOf: response)
                    for _ in 0...response.count {
                        self.cellSizes.append(self.generateRandomSize())
                    }
                    self.pagesLoaded = self.pagesLoaded + 1
                    self.collectionView.reloadData()
                    completion(true)
                case .failure(let error):
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                    completion(false)
                }
            }
        }
    }
    
}
