//
//  SearchResultCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-12.
//

import UIKit
import RandomColorSwift

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        avatar.roundCorners(style: .completely)
        avatar.layer.borderColor = UIColor.yellow.cgColor
        avatar.layer.borderWidth = 2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func config(unsplashPhoto: UnsplashPhoto) {
        if let url = URL(string: unsplashPhoto.urls.small) {
            avatar.kf.setImage(with: url)
        }
        avatar.layer.borderColor = randomColor(hue: .random, luminosity: .light).cgColor
        
        if let title = unsplashPhoto.descrip ?? unsplashPhoto.alt_description, !title.isEmpty {
            label1.text = title
            label1.isHidden = false
        } else {
            label1.isHidden = true
        }
        
        label2.text = unsplashPhoto.user.name
    }
    
    func config(unsplashCollection: UnsplashCollection) {
        if let url = URL(string: unsplashCollection.cover_photo.urls.small) {
            avatar.kf.setImage(with: url)
        }
        avatar.layer.borderColor = randomColor(hue: .random, luminosity: .light).cgColor
        label1.text = unsplashCollection.title
        label1.isHidden = false
        label2.text = unsplashCollection.user.name
    }
    
    func config(result: UnsplashSearchResult) {
        if let url = URL(string: result.cover_photo.urls.small) {
            avatar.kf.setImage(with: url)
        }
        avatar.layer.borderColor = randomColor(hue: .random, luminosity: .light).cgColor
        if let title = result.descrip, !title.isEmpty {
            label1.text = title
            label1.isHidden = false
        } else {
            label1.isHidden = true
        }
        
        label2.text = result.user.name
    }
}
