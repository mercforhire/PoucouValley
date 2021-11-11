//
//  GiftCollectionViewCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-10.
//

import UIKit

class GiftTableViewCell: UITableViewCell {
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var cardLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        background.roundCorners(style: .medium)
        cardLabel.roundCorners(style: .medium)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(unsplashPhoto: UnsplashPhoto) {
        if let url = URL(string: unsplashPhoto.urls.small) {
            background.kf.setImage(with: url)
        }
        cardLabel.text = "\(50 * Int.random(in: 1...10)) Coins - $\(5 * Int.random(in: 1...20)) Gift Card"
    }
}
