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
                plansCellSizes.append(generateRandomSize())
            }
            collectionView.reloadData()
        }
    }
    private var plansCellSizes: [CGSize] = []
    
    private var followed: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    private var shopDetailsCollectionHeaderView: ShopDetailsCollectionHeaderView?
    
    override func setup() {
        super.setup()
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(UINib(nibName: "ShopDetailsCollectionHeaderView", bundle: nil), forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withReuseIdentifier: "Header")
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
        api.fetchMerchantPlans(merchant: merchant) { [weak self] result in
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

}

extension ShopDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "Header",
                                                                         for: indexPath) as! ShopDetailsCollectionHeaderView
        
        self.shopDetailsCollectionHeaderView = headerView
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let headerView = shopDetailsCollectionHeaderView else { return CGSize.zero }
        
        var size = CGSize()
        let fitting = CGSize(width: headerView.frame.size.width, height: 1)
        size = headerView.systemLayoutSizeFitting(fitting,
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: UILayoutPriority(1))
        return size
        
    }
}


// MARK: - CollectionViewWaterfallLayoutDelegate
extension ShopDetailsViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return plansCellSizes[indexPath.item]
    }
}
