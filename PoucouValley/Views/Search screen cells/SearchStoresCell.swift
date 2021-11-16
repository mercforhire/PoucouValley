//
//  SearchStoresCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-12.
//

import UIKit

class SearchStoresCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    private var stores: [UnsplashPhoto]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(stores: [UnsplashPhoto]) {
        self.stores = stores
        collectionView.reloadData()
    }
}

extension SearchStoresCell: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stores?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchStoreCell", for: indexPath) as? SearchStoreCell, let store = stores?[indexPath.row] else { return UICollectionViewCell() }
        
        cell.config(store: store)
        return cell
    }
}
