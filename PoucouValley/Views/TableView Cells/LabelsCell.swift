//
//  LabelsCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-15.
//

import UIKit

class LabelsCell: UITableViewCell {

    @IBOutlet weak var label: ThemeBlackTextLabel!
    @IBOutlet weak var label2: ThemeBlackTextLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
