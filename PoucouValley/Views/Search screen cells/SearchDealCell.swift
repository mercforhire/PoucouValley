//
//  SearchDealCollectionViewCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-12.
//

import UIKit

class SearchDealCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.roundCorners(style: .medium)
        categoryImageView.roundCorners(style: .completely)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func config(unsplashPhoto: UnsplashPhoto, category: UnsplashTopic) {
        if let url = URL(string: unsplashPhoto.urls.small) {
            imageView.kf.setImage(with: url)
        }
        if let title = unsplashPhoto.description ?? unsplashPhoto.alt_description, !title.isEmpty {
            titleLabel.text = title
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
        
        if let url = URL(string: category.cover_photo.urls.small) {
            categoryImageView.kf.setImage(with: url)
        }
        categoryLabel.text = category.title
    }
    
}
