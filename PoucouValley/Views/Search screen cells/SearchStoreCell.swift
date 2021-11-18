//
//  SearchStoreCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-13.
//

import UIKit

class SearchStoreCell: UICollectionViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorView.roundCorners(style: .medium)
        imageView.roundCorners(style: .medium)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func config(store: UnsplashPhoto) {
        if let url = URL(string: store.urls.small) {
            imageView.kf.setImage(with: url)
        }
        if let title = store.descrip ?? store.alt_description, !title.isEmpty {
            label1.text = title
            label1.isHidden = false
        } else {
            label1.isHidden = true
        }
        
        label2.text = store.user.name
    }
}
