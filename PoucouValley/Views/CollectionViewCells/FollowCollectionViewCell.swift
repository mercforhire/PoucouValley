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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.roundCorners(style: .medium)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(plan: Plan) {
        if let thumbnailUrlString = plan.photos.first?.thumbnailUrl,
            let url = URL(string: thumbnailUrlString) {
            imageView.kf.setImage(with: url)
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
