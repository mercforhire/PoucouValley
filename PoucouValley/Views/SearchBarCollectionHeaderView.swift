//
//  SearchBarCollectionHeaderView.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-18.
//

import UIKit

class SearchBarCollectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        searchBar.backgroundImage = UIImage()
    }
}
