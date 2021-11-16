//
//  LabelCollectionViewCell.swift
//  CollectionViewWaterfallLayoutDemo
//
//  Created by Eric Cerney on 9/24/19.
//  Copyright © 2019 Eric Cerney. All rights reserved.
//

import UIKit
import Kingfisher

class FollowCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var pin: UIImageView!
    @IBOutlet weak var label3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.roundCorners(style: .medium)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(unsplashPhoto: UnsplashPhoto) {
        if let url = URL(string: unsplashPhoto.urls.small) {
            imageView.kf.setImage(with: url)
        }
        if let title = unsplashPhoto.description ?? unsplashPhoto.alt_description, !title.isEmpty {
            label1.text = title
            label1.isHidden = false
        } else {
            label1.isHidden = true
        }
        
        label2.text = unsplashPhoto.user.name
        
        if let location = unsplashPhoto.user.location {
            label3.text = location
            pin.isHidden = false
            label3.isHidden = false
        } else {
            pin.isHidden = true
            label3.isHidden = true
        }
    }
}
