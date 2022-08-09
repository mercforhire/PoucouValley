//
//  PlanDetailsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-05.
//

import UIKit
import CollectionViewWaterfallLayout
import CRRefresh

class PlanDetailsViewController: BaseViewController {
    var plan: Plan!
    var merchant: Merchant!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var relatedPlans: [Plan]? {
        didSet {
            cellSizes.removeAll()
            for _ in 0...(relatedPlans?.count ?? 0) {
                cellSizes.append(generateRandomSize(collectionView: collectionView))
            }
            collectionView.reloadData()
        }
    }
    private var followed: Bool = false {
        didSet {
            headerView?.config(plan: plan, merchant: merchant, following: followed, showPostSection: !(relatedPlans?.isEmpty ?? true))
        }
    }
    private var cellSizes: [CGSize] = []
    private var headerView: PlanDetailsCollectionHeaderView?
    
    override func setup() {
        super.setup()
        
        title = plan.title
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerHeight = 1
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        collectionView.register(UINib(nibName: "PlanDetailsCollectionHeaderView", bundle: nil), forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withReuseIdentifier: "Header")
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView?.config(plan: plan, merchant: merchant, following: followed, showPostSection: !(relatedPlans?.isEmpty ?? true))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        fetchContent { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.collectionView.reloadData()
            }
        }
    }
    
    private func fetchContent(complete: ((Bool) -> Void)? = nil) {
        api.fetchMerchantPlans(merchant: merchant) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.success {
                    self.relatedPlans = Array(response.data)
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
    
    @objc private func followButtonPressed() {
        FullScreenSpinner().show()
        
        if (!followed) {
            api.followMerchant(userId: merchant.userId) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self.followed = true
                    } else {
                        showErrorDialog(error: response.message)
                    }
                case .failure:
                    showNetworkErrorDialog()
                }
            }
        } else {
            api.unfollowMerchant(userId: merchant.userId) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self.followed = false
                    } else {
                        showErrorDialog(error: response.message)
                    }
                case .failure:
                    showNetworkErrorDialog()
                }
            }
        }
    }
    
    @objc private func merchantLogoPressed() {
        let vc = StoryboardManager.loadViewController(storyboard: "Shops", viewControllerId: "ShopDetailsViewController") as! ShopDetailsViewController
        vc.merchant = merchant
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PlanDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "Header",
                                                                         for: indexPath) as! PlanDetailsCollectionHeaderView
        
        self.headerView = headerView
        headerView.config(plan: plan, merchant: merchant, following: followed, showPostSection: !(relatedPlans?.isEmpty ?? true))
        headerView.followButton.addTarget(self, action: #selector(followButtonPressed), for: .touchUpInside)
        headerView.logoButton.addTarget(self, action: #selector(merchantLogoPressed), for: .touchUpInside)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return relatedPlans?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowCollectionViewCell", for: indexPath) as? FollowCollectionViewCell else { return UICollectionViewCell() }
        
        guard let plan = relatedPlans?[indexPath.row] else {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let plan = relatedPlans?[indexPath.row] else { return }
        
        openPlanDetailsVC(plan: plan)
    }
}


// MARK: - CollectionViewWaterfallLayoutDelegate
extension PlanDetailsViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if relatedPlans?.count ?? 0 == 0 {
            return collectionView.frame.size
        }
        
        return cellSizes[indexPath.item]
    }
}

