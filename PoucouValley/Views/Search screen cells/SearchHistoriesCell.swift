//
//  SearchHistoriesCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-12.
//

import UIKit

class SearchHistoriesCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var histories: [String]?
    private var clickAction: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(histories: [String], clickAction: @escaping ((String) -> Void)) {
        self.histories = histories
        self.clickAction = clickAction
        collectionView.reloadData()
    }
}

extension SearchHistoriesCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return histories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchHistoryCell", for: indexPath) as? SearchHistoryCell, let history = histories?[indexPath.row] else { return UICollectionViewCell() }
        
        cell.config(history: history)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let history = histories?[indexPath.row] else { return }
        
        clickAction?(history)
    }
}
