//
//  ShopDetailsCollectionHeaderView.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-02.
//

import UIKit

class ShopDetailsCollectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: ThemeUIPageControl!
    @IBOutlet weak var logoImageView: URLImageView!
    @IBOutlet weak var shopNameLabel: ThemeBlackTextLabel!
    @IBOutlet weak var numberFollowersLabel: ThemeDarkLabel!
    @IBOutlet weak var followButton: ThemeGreenButton!
    @IBOutlet weak var shopCategoryLabel: ThemeBlackTextLabel!
    @IBOutlet weak var shopDescriptionLabel: ThemeBlackTextLabel!
    @IBOutlet weak var hashtagsLabel: ThemeDarkLabel!
    
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
        numberFollowersLabel.text = ""
        shopCategoryLabel.text = ""
        shopDescriptionLabel.text = ""
        hashtagsLabel.text = ""
    }
    
    func config(data: Merchant, following: Bool) {
        photos = Array(data.photos)
        
        if let logo = data.logo {
            logoImageView.loadImageFromURL(urlString: logo.thumbnailUrl)
        } else if let firstPhoto = data.photos.first {
            logoImageView.loadImageFromURL(urlString: firstPhoto.thumbnailUrl)
        } else {
            logoImageView.image = UIImage(named: "store")
        }
        
        shopNameLabel.text = data.name
        numberFollowersLabel.text = numberFollowersLabel.text?.replacingOccurrences(of: "[X]", with: "\(data.visits ?? 0)")
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

extension ShopDetailsCollectionHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
