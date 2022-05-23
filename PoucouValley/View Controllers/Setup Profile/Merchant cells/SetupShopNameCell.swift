//
//  SetupShopNameCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-22.
//

import UIKit

class SetupShopNameCell: UITableViewCell {

    @IBOutlet weak var nameField: ThemeTextField!
    @IBOutlet weak var submitButton: ThemeRoundedGreenBlackTextButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
