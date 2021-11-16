//
//  SearchNoResultCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-12.
//

import UIKit

class SearchNoResultCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(keyWord: String) {
        label.text = label.text?.replacingOccurrences(of: "[KEYWORD]", with: keyWord)
    }
}
