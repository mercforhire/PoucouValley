//
//  CardholderContactInfoCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-31.
//

import UIKit
import RealmSwift

class CardholderContactInfoCell: UITableViewCell {

    @IBOutlet weak var containerView: RoundedBorderView!
    
    @IBOutlet weak var phoneLabel: ThemeBlackTextLabel!
    @IBOutlet weak var addressLabel: ThemeBlackTextLabel!
    @IBOutlet weak var updateButton: ThemeRoundedGreenBlackTextButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(user: UserDetails) {
        guard let cardholder = user.cardholder else {
            phoneLabel.text = "--"
            addressLabel.text = "--"
            return
        }
        
        if let contact = cardholder.contact {
            phoneLabel.text = "\(contact.phoneAreaCode ?? "")\(contact.phoneNumber ?? "")"
        } else {
            phoneLabel.text = "--"
        }
        
        addressLabel.text = cardholder.address?.addressString
    }
}
