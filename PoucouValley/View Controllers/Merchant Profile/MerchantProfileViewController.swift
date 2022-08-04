//
//  MerchantProfileViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-02.
//

import UIKit
import CollectionViewWaterfallLayout

class MerchantProfileViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var merchant: Merchant {
        return userManager.user!.merchant!
    }
    
    private var plans: [Plan]? {
        didSet {
            cellSizes.removeAll()
            for _ in 0...(plans?.count ?? 0) {
                cellSizes.append(generateRandomSize())
            }
            collectionView.reloadData()
        }
    }
    private var selectedPlan: Plan?
    private var cellSizes: [CGSize] = []
    private var collectionHeaderView: MerchantDetailsHeaderView?
    
    override func setup() {
        super.setup()
        
        title = merchant.name
        
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
        
        userManager.fetchUser { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.refreshViewController()
            }
        }
        
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
    
    private func refreshViewController() {
        title = merchant.name
        collectionHeaderView?.config(data: merchant)
    }
    
    private func generateRandomSize() -> CGSize {
        let width: Double = Double(collectionView.frame.width) - 10 * 3
        let random = Double(arc4random_uniform((UInt32(width * 1.5))))
        let randomSize = CGSize(width: width, height: width + random)
        return randomSize
    }
    
    @objc func addPostButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToNewPost", sender: self)
    }
    
    @objc func editPostPressed(plan: Plan) {
        selectedPlan = plan
        performSegue(withIdentifier: "goToEditPost", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditPostViewController,
            let selectedPlan = selectedPlan {
            vc.plan = selectedPlan
        }
    }
}

extension MerchantProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "Header",
                                                                         for: indexPath) as! MerchantDetailsHeaderView
        
        self.collectionHeaderView = headerView
        headerView.config(data: merchant)
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
        if plans?.count ?? 0 == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyPostsCell", for: indexPath) as? EmptyPostsCell else { return EmptyPostsCell() }
            cell.button.tag = indexPath.row
            cell.button.addTarget(self, action: #selector(addPostButtonPressed), for: .touchUpInside)
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowCollectionViewCell", for: indexPath) as? FollowCollectionViewCell else { return UICollectionViewCell() }
        
        guard let plan = plans?[indexPath.row] else {
            return cell
        }
        cell.config(plan: plan)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let headerView = collectionHeaderView else { return CGSize.zero }
        
        var size = CGSize()
        let fitting = CGSize(width: headerView.frame.size.width, height: 1)
        size = headerView.systemLayoutSizeFitting(fitting,
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: UILayoutPriority(1))
        return size
    }
}


// MARK: - CollectionViewWaterfallLayoutDelegate
extension MerchantProfileViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if plans?.count ?? 0 == 0 {
            return collectionView.frame.size
        }
        
        return cellSizes[indexPath.item]
    }
}