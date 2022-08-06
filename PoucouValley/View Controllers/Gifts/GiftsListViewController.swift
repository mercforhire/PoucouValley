//
//  GiftsListViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-05.
//

import UIKit
import CollectionViewWaterfallLayout
import CRRefresh

class GiftsListViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var gifts: [Gift]? {
        didSet {
            cellSizes.removeAll()
            for _ in 0...(gifts?.count ?? 0) {
                cellSizes.append(generateRandomSize(collectionView: collectionView))
            }
            collectionView.reloadData()
        }
    }
    private var clickedGift: Gift?
    
    private var cellSizes: [CGSize] = []
    
    override func setup() {
        super.setup()
        
        let layout = CollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerHeight = 0
        layout.footerHeight = 0
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
        collectionView.alwaysBounceVertical = true
        collectionView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            guard let self = self else { return }
            
            self.fetchContent()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }

    private func fetchContent(complete: ((Bool) -> Void)? = nil) {
        gifts == nil ? FullScreenSpinner().show() : nil
        
        api.fetchGifts { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            self.collectionView.cr.endHeaderRefresh()
            
            switch result {
            case .success(let response):
                if response.success {
                    self.gifts = Array(response.data)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GiftDetailViewController, let clickedGift = clickedGift {
            vc.gift = clickedGift
        }
    }
}

extension GiftsListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(1, gifts?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if gifts?.count ?? 0 == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyLikedCell", for: indexPath)
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowCollectionViewCell", for: indexPath) as? FollowCollectionViewCell, let gift = gifts?[indexPath.row] else { return UICollectionViewCell() }
        cell.config(gift: gift)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let gift = gifts?[indexPath.row] else { return }
        
        clickedGift = gift
        performSegue(withIdentifier: "goToGift", sender: self)
    }
}


// MARK: - CollectionViewWaterfallLayoutDelegate
extension GiftsListViewController: CollectionViewWaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if gifts?.count ?? 0 == 0 {
            return CGSize(width: collectionView.frame.width - 20, height: collectionView.frame.height / 2)
        }
        
        return cellSizes[indexPath.row]
    }
}
