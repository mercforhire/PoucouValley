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
    
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var stories: [UnsplashPhoto]?
    private var content: [UnsplashPhoto]?
    private let cellWidth: CGFloat = 80.0
    
    lazy var cellSizes: [CGSize] = {
        var cellSizes = [CGSize]()
        
        for _ in 0...(content?.count ?? 0) {

            let width: Double = Double(collectionView.frame.width) - 10 * 3
            let random = Double(arc4random_uniform((UInt32(width * 1.5))))
            
            cellSizes.append(CGSize(width: width, height: width + random))
        }
        
        return cellSizes
    }()
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = .init(width: cellWidth, height: storiesCollectionView.frame.height - 20)
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = 10
        flowlayout.minimumInteritemSpacing = 10
        flowlayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        storiesCollectionView.setCollectionViewLayout(flowlayout, animated: false)
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerHeight = 0
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchContent()
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
        
        api.getPhotos { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.content = response
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
}

extension HomeExploreViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as? StoryCollectionViewCell, let story = stories?[indexPath.row] else { return UICollectionViewCell() }
            
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
