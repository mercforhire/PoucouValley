//
//  StoryCollectionViewCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-08.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label1: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        outlineView.roundCorners(style: .completely)
        imageView.roundCorners(style: .completely)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(unsplashPhoto: UnsplashPhoto) {
        outlineView.roundCorners(style: .completely)
        imageView.roundCorners(style: .completely)
        
        if let url = URL(string: unsplashPhoto.urls.small) {
            imageView.kf.setImage(with: url)
        }
        label1.text = unsplashPhoto.user.name
    }
}
