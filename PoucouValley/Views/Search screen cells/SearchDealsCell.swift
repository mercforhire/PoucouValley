//
//  SearchDealsCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-12.
//

import UIKit

class SearchDealsCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    private var deals: [UnsplashPhoto]?
    private var categories: [UnsplashTopic]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(deals: [UnsplashPhoto], categories: [UnsplashTopic]) {
        self.deals = deals
        self.categories = categories
        collectionView.reloadData()
    }
}

extension SearchDealsCell: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deals?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchDealCell", for: indexPath) as? SearchDealCell, let deal = deals?[indexPath.row], let category = categories?.randomElement() else { return UICollectionViewCell() }
        
        cell.config(unsplashPhoto: deal, category: category)
        return cell
    }
}
