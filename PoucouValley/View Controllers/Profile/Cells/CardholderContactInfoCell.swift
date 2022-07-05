//
//  CardholderContactInfoCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-31.
//

import UIKit
import PhoneNumberKit
import RealmSwift

class CardholderContactInfoCell: UITableViewCell {

    @IBOutlet weak var containerView: RoundedBorderView!
    
    @IBOutlet weak var phoneLabel: ThemeBlackTextLabel!
    @IBOutlet weak var addressLabel: ThemeBlackTextLabel!
    @IBOutlet weak var updateButton: ThemeRoundedGreenBlackTextButton!
    private let phoneNumberKit = PhoneNumberKit()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        PhoneNumberKit.CountryCodePicker.commonCountryCodes = ["US", "CA"]
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
        
        if let contact = cardholder.contact, let phoneNumber = try? phoneNumberKit.parse("\(contact.phoneAreaCode ?? "")\(contact.phoneNumber ?? "")")  {
            phoneLabel.text = phoneNumber.numberString
        } else {
            phoneLabel.text = "--"
        }
        
        addressLabel.text = cardholder.address?.addressString
    }
}
