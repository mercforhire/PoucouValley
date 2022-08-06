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
    private var selectedPlan: Plan?
    private var followed: Bool = false {
        didSet {
            headerView?.config(plan: plan, merchant: merchant, following: followed)
        }
    }
    private var cellSizes: [CGSize] = []
    private var headerView: PlanDetailsCollectionHeaderView?
    
    override func setup() {
        super.setup()
        
        title = plan.title
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(UINib(nibName: "MerchantDetailsHeaderView", bundle: nil), forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withReuseIdentifier: "Header")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        api.followMerchant(merchantId: merchant.identifier) { [weak self] result in
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
    }
    
    private func refreshViewController() {
        headerView?.config(plan: plan, merchant: merchant, following: followed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PlanDetailsViewController,
            let selectedPlan = selectedPlan {
            vc.plan = selectedPlan
        }
    }
}

extension PlanDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "Header",
                                                                         for: indexPath) as! PlanDetailsCollectionHeaderView
        
        self.headerView = headerView
        headerView.config(plan: plan, merchant: merchant, following: followed)
        headerView.followButton.addTarget(self, action: #selector(followButtonPressed), for: .touchUpInside)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let headerView = headerView else { return CGSize.zero }
        
        var size = CGSize()
        let fitting = CGSize(width: headerView.frame.size.width, height: 1)
        size = headerView.systemLayoutSizeFitting(fitting,
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: UILayoutPriority(1))
        return size
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

