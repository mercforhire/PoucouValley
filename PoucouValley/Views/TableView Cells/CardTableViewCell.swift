//
//  CardTableViewCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-11.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var cardholderLabel: UILabel!
    @IBOutlet weak var avatar: URLImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        avatar.roundCorners(style: .completely)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(card: Card) {
        numberLabel.text = card.number
        
        if let cardholder = card.associatedCardholder {
            cardholderLabel.text = card.associatedCardholder?.fullName
            
            if let thumbnailUrl = card.associatedCardholder?.avatar?.thumbnailUrl, !thumbnailUrl.isEmpty {
                avatar.loadImageFromURL(urlString: thumbnailUrl)
            } else {
                avatar.image = UIImage(systemName: "person.fill")
            }
        } else {
            cardholderLabel.text = "Not linked to user."
            avatar.image = nil
        }
    }
}
