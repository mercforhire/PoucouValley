//
//  MerchantTableViewCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-31.
//

import UIKit

class MerchantTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoView: URLImageView!
    @IBOutlet weak var nameLabel: ThemeBlackTextLabel!
    @IBOutlet weak var categoryIconImageView: ThemeGreenImageView!
    @IBOutlet weak var categoryLabel: ThemeGreenTextLabel!
    @IBOutlet weak var visitorsLabel: ThemeDarkLabel!
    @IBOutlet weak var followersLabel: ThemeDarkLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.addShadow(style: .medium)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(merchant: Merchant) {
        if let fullUrl = merchant.photos.first?.fullUrl {
            logoView.loadImageFromURL(urlString: fullUrl)
        } else {
            logoView.image = nil
        }
        
        nameLabel.text = merchant.name
        categoryIconImageView.image = merchant.category.icon()
        categoryLabel.text = merchant.category.rawValue
        visitorsLabel.text = visitorsLabel.text?.replacingOccurrences(of: "[X]", with: "\(merchant.visits ?? 0)")
        followersLabel.text = visitorsLabel.text?.replacingOccurrences(of: "[X]", with: "\(merchant.followers ?? 0)")
    }
}
