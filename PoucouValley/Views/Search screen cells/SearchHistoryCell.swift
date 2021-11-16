//
//  SearchHistoryCollectionViewCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-12.
//

import UIKit

class SearchHistoryCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(history: String) {
        label.text = history
    }
}
