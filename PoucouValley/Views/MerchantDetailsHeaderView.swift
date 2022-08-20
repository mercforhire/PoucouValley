//
//  MerchantDetailsHeaderView.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-03.
//

import UIKit
import UILabel_Copyable

class MerchantDetailsHeaderView: UICollectionReusableView {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: ThemeUIPageControl!
    
    @IBOutlet weak var topRoundedView: ThemeBackView!
    @IBOutlet weak var visitsLabel: ThemeBlackTextLabel!
    @IBOutlet weak var followersLabel: ThemeBlackTextLabel!
    @IBOutlet weak var logoImageView: URLImageView!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var merchantNameLabel: ThemeBlackTextLabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var igButton: UIButton!
    @IBOutlet weak var twitButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    
    @IBOutlet weak var addressLabel: ThemeBlackTextLabel!
    @IBOutlet weak var addPostButton: ThemeBlackBgWhiteTextButton!
    
    var photos: [PVPhoto] = [] {
        didSet {
            pageControl.numberOfPages = photos.count
            collectionView.reloadData()
            
            if !photos.isEmpty {
                collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addressLabel.isCopyingEnabled = true
        collectionView.register(UINib(nibName: "URLImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        logoImageView.roundCorners(style: .medium)
        editButton.roundCorners(style: .completely)
        editButton.addBorder(color: .black)
        pageControl.numberOfPages = 1
        visitsLabel.text = "--"
        followersLabel.text = "--"
        logoImageView.image = nil
        addressLabel.text = ""
        merchantNameLabel.text = ""
        addPostButton.roundCorners(style: .small)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topRoundedView.roundSelectedCorners(corners: [.topLeft, .topRight], radius: 30)
        collectionView.reloadData()
    }
    
    func config(data: Merchant) {
        if let logo = data.logo?.thumbnailUrl, !logo.isEmpty {
            logoImageView.loadImageFromURL(urlString: logo)
        } else if let firstPhoto = data.photos.first?.thumbnailUrl, !firstPhoto.isEmpty {
            logoImageView.loadImageFromURL(urlString: firstPhoto)
        } else {
            logoImageView.image = UIImage(named: "store")
        }
        merchantNameLabel.text = data.name
        visitsLabel.text = "\(data.visits ?? 0)"
        followersLabel.text = "\(data.followers ?? 0)"
        addressLabel.text = data.address?.addressString ?? "No address provided"
        photos = Array(data.photos)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let centerCell = collectionView.centerMostCell else { return }
        
        let indexPath = collectionView.indexPath(for: centerCell)
        pageControl.currentPage = indexPath?.row ?? 0
    }
}

extension MerchantDetailsHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! URLImageCollectionViewCell
        
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
