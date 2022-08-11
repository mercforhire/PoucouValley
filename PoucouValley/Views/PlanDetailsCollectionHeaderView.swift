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
    @IBOutlet weak var logoButton: UIButton!
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
    @IBOutlet weak var followButtonContainer: UIView!
    @IBOutlet weak var followButton: ThemeRoundedGreenWhiteTextButton!
    @IBOutlet weak var postsSection: UIView!
    
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
        
        logoImageView.roundCorners(style: .completely)
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
    
    func config(plan: Plan, merchant: Merchant, following: Bool, showPostSection: Bool) {
        photos = Array(plan.photos)
        
        if let logo = merchant.logo?.thumbnailUrl, !logo.isEmpty {
            logoImageView.loadImageFromURL(urlString: logo)
        } else if let firstPhoto = merchant.photos.first?.thumbnailUrl, !firstPhoto.isEmpty {
            logoImageView.loadImageFromURL(urlString: firstPhoto)
        } else {
            logoImageView.image = UIImage(named: "store")
        }
        
        shopNameLabel.text = merchant.name
        numberFollowersLabel.text = "\(merchant.followers ?? 0) followers"
        
        titleLabel.text = plan.title
        
        if let price = plan.price, let discountedPrice = plan.discountedPrice {
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: price.df2so())
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            originalPriceLabel.attributedText = attributeString
            discountedPriceLabel.text = discountedPrice.df2so()
            priceLabelsContainer.isHidden = false
        } else if let price = plan.price {
            originalPriceLabel.text = price.df2so()
            discountedPriceLabel.text = ""
            priceLabelsContainer.isHidden = false
        } else {
            priceLabelsContainer.isHidden = true
        }
        
        planDescriptionLabel.text = plan.planDescription
        
        var tagsString = ""
        for tag in plan.hashtags {
            if tag == plan.hashtags.first {
                tagsString = "#\(tag)"
            } else {
                tagsString = "\(tagsString), #\(tag)"
            }
        }
        hashtagsLabel.text = tagsString
        
        if following {
            followButtonContainer.isHidden = true
        } else {
            followButtonContainer.isHidden = false
        }
        
        postsSection.isHidden = !showPostSection
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
