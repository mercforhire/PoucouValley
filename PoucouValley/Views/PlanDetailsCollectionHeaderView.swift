//
//  PlanDetailsCollectionHeaderView.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-05.
//

import UIKit

class PlanDetailsCollectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: ThemeUIPageControl!
    @IBOutlet weak var logoImageView: URLImageView!
    @IBOutlet weak var shopNameLabel: ThemeBlackTextLabel!
    @IBOutlet weak var numberFollowersLabel: ThemeDarkLabel!
    
    @IBOutlet weak var likeButtonContainer: UIView!
    @IBOutlet weak var heartIcon: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var titleLabel: ThemeBlackTextLabel!
    @IBOutlet weak var priceLabelsContainer: UIView!
    @IBOutlet weak var originalPriceLabel: ThemeDarkLabel!
    @IBOutlet weak var discountedPriceLabel: ThemeDarkLabel!
    @IBOutlet weak var planDescriptionLabel: ThemeBlackTextLabel!
    @IBOutlet weak var hashtagsLabel: ThemeDarkLabel!
    @IBOutlet weak var followButton: ThemeRoundedGreenWhiteTextButton!
    
    var photos: [PVPhoto] = [] {
        didSet {
            pageControl.numberOfPages = photos.count
            collectionView.reloadData()
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: "URLImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        pageControl.numberOfPages = 1
        shopNameLabel.text = ""
        numberFollowersLabel.text = "-- followers"
        titleLabel.text = ""
        
        priceLabelsContainer.isHidden = true
        originalPriceLabel.text = ""
        discountedPriceLabel.text = ""
        
        planDescriptionLabel.text = ""
        hashtagsLabel.text = ""
    }
    
    func config(data: Plan, following: Bool) {
        photos = Array(data.photos)
        
        if let logo = data.logo {
            logoImageView.loadImageFromURL(urlString: logo.thumbnailUrl)
        } else if let firstPhoto = data.photos.first {
            logoImageView.loadImageFromURL(urlString: firstPhoto.thumbnailUrl)
        } else {
            logoImageView.image = UIImage(named: "store")
        }
        
        shopNameLabel.text = data.name
        numberFollowersLabel.text = "\(data.followers ?? 0) followers"
        shopCategoryLabel.text = data.field
        shopDescriptionLabel.text = data.merchantDescription
        
        var tagsString = "#"
        for tag in data.hashtags {
            tagsString = "\(tagsString), #\(tag)"
        }
        hashtagsLabel.text = tagsString
        
        followButton.setTitle(following ? "Unfolllow" : "Follow", for: .normal)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let centerCell = collectionView.centerMostCell else { return }
        
        let indexPath = collectionView.indexPath(for: centerCell)
        pageControl.currentPage = indexPath?.row ?? 0
    }
    
}


extension PlanDetailsCollectionHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? URLImageCollectionViewCell else { return URLImageCollectionViewCell() }
        
        let photo = photos[indexPath.row]
        cell.imageView.loadImageFromURL(urlString: photo.fullUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
