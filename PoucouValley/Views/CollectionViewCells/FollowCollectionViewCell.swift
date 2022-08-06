//
//  LabelCollectionViewCell.swift
//  CollectionViewWaterfallLayoutDemo
//
//  Created by Eric Cerney on 9/24/19.
//  Copyright © 2019 Eric Cerney. All rights reserved.
//

import UIKit

class FollowCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: URLImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.roundCorners(style: .medium)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(plan: Plan) {
        if let thumbnailUrlString = plan.photos.first?.thumbnailUrl {
            imageView.loadImageFromURL(urlString: thumbnailUrlString)
        } else {
            imageView.image = nil
        }
        
        if let title = plan.title, !title.isEmpty {
            label1.text = title
            label1.isHidden = false
        } else {
            label1.isHidden = true
        }
        
        label2.text = plan.planDescription
    }
    
    func config(gift: Gift) {
        if let thumbnailUrlString = gift.photos.first?.thumbnailUrl {
            imageView.loadImageFromURL(urlString: thumbnailUrlString)
        } else {
            imageView.image = nil
        }
        
        if !gift.name.isEmpty {
            label1.text = gift.name
            label1.isHidden = false
        } else {
            label1.isHidden = true
        }
        
        if !gift.itemDescription.isEmpty {
            label1.text = "\(label1.text ?? "")-\(gift.itemDescription)"
            label1.isHidden = false
        }
        
        label2.text = gift.itemDescription2
    }
    
    func config(merchant: Merchant) {
        if let thumbnailUrlString = merchant.logo?.thumbnailUrl,
            let url = URL(string: thumbnailUrlString) {
            imageView.kf.setImage(with: url)
        }
        if let title = merchant.name, !title.isEmpty {
            label1.text = title
            label1.isHidden = false
        } else {
            label1.isHidden = true
        }
        
        label2.text = merchant.field
    }
}
