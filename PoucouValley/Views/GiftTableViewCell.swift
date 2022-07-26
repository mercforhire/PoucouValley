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
    
    func config(data: Gift) {
        if let photoUrl = data.photos.first,
            let url = URL(string: photoUrl) {
            background.kf.setImage(with: url)
        }
        cardLabel.text = "\(data.costInCoins) Coins - \(data.name)"
    }
}
