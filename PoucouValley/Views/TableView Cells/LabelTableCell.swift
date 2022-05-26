//
//  LabelTableCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class LabelTableCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
