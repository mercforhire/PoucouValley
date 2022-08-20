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
                cellSizes.append(generateRandomSize(collectionView: collectionView))
            }
            layout.columnCount = (plans?.isEmpty ?? true) ? 1 : 2
            collectionView.reloadData()
        }
    }
    private var selectedPlan: Plan?
    private var cellSizes: [CGSize] = []
    private var headerView: MerchantDetailsHeaderView?
    private let layout = CollectionViewWaterfallLayout()
    private lazy var composer: MessageComposer = MessageComposer()
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func setup() {
        super.setup()
        
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.columnCount = 1
        layout.headerHeight = 1
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
        
        navigationController?.isNavigationBarHidden = false
        
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
    
    private func refreshViewController() {
        headerView?.config(data: merchant)
    }
    
    @objc func addPostButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToNewPost", sender: self)
    }
    
    @objc func editMerchantButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToEditMerchant", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditPostViewController,
            let selectedPlan = selectedPlan {
            vc.plan = selectedPlan
        }
    }
    
    @objc func phoneButtonPressed(_ sender: UIButton) {
        guard let phoneNumber = merchant.contact?.getPhoneNumberString(), !phoneNumber.isEmpty else {
            showErrorDialog(error: "Phone number not set")
            return
        }
        
        if composer.canCall(phoneNumber: phoneNumber) {
            composer.call(phoneNumber: phoneNumber)
        } else {
            showErrorDialog(error: "Can't call on this device.")
        }
    }
    
    @objc func webButtonPressed(_ sender: UIButton) {
        guard let urlString = merchant.contact?.website, let url = URL(string: urlString) else {
            showErrorDialog(error: "Website URL not set")
            return
        }
        
        openURLInBrowser(url: url)
    }
    
    @objc func igButtonPressed(_ sender: UIButton) {
        guard let urlString = merchant.contact?.instagram, let url = URL(string: urlString) else {
            showErrorDialog(error: "Instagram URL not set")
            return
        }
        
        openURLInBrowser(url: url)
    }
    
    @objc func twitButtonPressed(_ sender: UIButton) {
        guard let urlString = merchant.contact?.twitter, let url = URL(string: urlString) else {
            showErrorDialog(error: "Twitter URL not set")
            return
        }
        
        openURLInBrowser(url: url)
    }
    
    @objc func fbButtonPressed(_ sender: UIButton) {
        guard let urlString = merchant.contact?.facebook, let url = URL(string: urlString) else {
            showErrorDialog(error: "Facebook URL not set")
            return
        }
        
        openURLInBrowser(url: url)
    }
}

extension MerchantProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "Header",
                                                                         for: indexPath) as! MerchantDetailsHeaderView
        
        self.headerView = headerView
        headerView.config(data: merchant)
        headerView.editButton.addTarget(self, action: #selector(editMerchantButtonPressed), for: .touchUpInside)
        headerView.phoneButton.addTarget(self, action: #selector(phoneButtonPressed), for: .touchUpInside)
        headerView.webButton.addTarget(self, action: #selector(webButtonPressed), for: .touchUpInside)
        headerView.igButton.addTarget(self, action: #selector(igButtonPressed), for: .touchUpInside)
        headerView.twitButton.addTarget(self, action: #selector(twitButtonPressed), for: .touchUpInside)
        headerView.fbButton.addTarget(self, action: #selector(fbButtonPressed), for: .touchUpInside)
        headerView.addPostButton.addTarget(self, action: #selector(addPostButtonPressed), for: .touchUpInside)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(1, plans?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if plans?.count ?? 0 == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyPostsCell", for: indexPath) as? EmptyPostsCell else { return EmptyPostsCell() }
            return cell
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let plan = plans?[indexPath.row] else { return }
        
        selectedPlan = plan
        performSegue(withIdentifier: "goToEditPost", sender: self)
    }
}


// MARK: - CollectionViewWaterfallLayoutDelegate
extension MerchantProfileViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if plans?.count ?? 0 == 0 {
            return CGSize(width: collectionView.frame.width - 20, height: collectionView.frame.height / 3)
        }
        
        return cellSizes[indexPath.item]
    }
}
