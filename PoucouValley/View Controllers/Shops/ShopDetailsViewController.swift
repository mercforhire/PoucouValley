//
//  ShopDetailsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-02.
//

import UIKit
import CollectionViewWaterfallLayout

class ShopDetailsViewController: BaseViewController {
    var merchant: Merchant!
    
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
    private var plansCellSizes: [CGSize] = []
    
    private var followed: Bool = false {
        didSet {
            headerView?.config(data: merchant, following: followed)
        }
    }
    private var headerView: ShopDetailsCollectionHeaderView?
    
    override func setup() {
        super.setup()
        
        title = merchant.name
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerHeight = 1
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "ShopDetailsCollectionHeaderView", bundle: nil), forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withReuseIdentifier: "Header")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView?.config(data: merchant, following: followed)
        fetchContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    private func fetchContent() {
        api.fetchMerchantPlans(merchant: merchant) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.success {
                    self.plans = Array(response.data)
                }
            case .failure:
                break
            }
        }
        
        api.fetchFollowShopStatus(merchant: merchant) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.success, let followed = response.data {
                    self.followed = followed
                }
            case .failure:
                break
            }
        }
    }
}

extension ShopDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "Header",
                                                                         for: indexPath) as! ShopDetailsCollectionHeaderView
        
        self.headerView = headerView
        headerView.config(data: merchant, following: followed)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plans?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowCollectionViewCell", for: indexPath) as? FollowCollectionViewCell else { return UICollectionViewCell() }
        
        guard let plan = plans?[indexPath.row] else {
            return cell
        }
        cell.config(plan: plan)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> Float {
        guard let headerView = headerView else { return 1 }
        
        // Use this view to calculate the optimal size based on the collection view's width
        let size = headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                      withHorizontalFittingPriority: .required, // Width is fixed
                                                      verticalFittingPriority: .fittingSizeLevel) // Height can be as large as needed
        return Float(size.height)
    }
}


// MARK: - CollectionViewWaterfallLayoutDelegate
extension ShopDetailsViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return plansCellSizes[indexPath.item]
    }
}
