//
//  CardholderBasicInfoCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-29.
//

import UIKit

class CardholderBasicInfoCell: UITableViewCell {

    @IBOutlet weak var containerView: RoundedBorderView!
    
    @IBOutlet weak var nameLabel: ThemeBlackTextLabel!
    @IBOutlet weak var genderLabel: ThemeBlackTextLabel!
    @IBOutlet weak var birthdayLabel: ThemeBlackTextLabel!
    @IBOutlet weak var emailLabel: ThemeBlackTextLabel!
    
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
        emailLabel.text = user.user?.email
        
        guard let cardholder = user.cardholder else {
            nameLabel.text = "--"
            genderLabel.text = "--"
            birthdayLabel.text = "--"
            return
        }
        
        nameLabel.text = cardholder.fullName
        genderLabel.text = cardholder.gender
        birthdayLabel.text = cardholder.birthday?.dateString
    }
}
