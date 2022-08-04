//
//  SimpleImageCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-29.
//

import UIKit

class SimpleImageCell: UICollectionViewCell {
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class URLImageTopRightButtonCell: UICollectionViewCell {
    @IBOutlet weak var imageView: URLImageView!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class SimpleURLImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: URLImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
