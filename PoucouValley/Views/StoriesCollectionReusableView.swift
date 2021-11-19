//
//  StoriesCollectionReusableView.swift
//  PoucouValley
//
//  Created by Leon Chen on 2021-11-18.
//

import UIKit

class StoriesCollectionReusableView: UICollectionReusableView {
    var stories: [UnsplashPhoto]?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellWidth: CGFloat = 73.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = .init(width: cellWidth, height: 80)
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = 0
        flowlayout.minimumInteritemSpacing = 0
        flowlayout.sectionInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        
        collectionView.setCollectionViewLayout(flowlayout, animated: false)
        collectionView.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoryCollectionViewCell")
        
        searchBar.backgroundImage = UIImage()
    }
}

extension StoriesCollectionReusableView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as? StoryCollectionViewCell,
                let story = stories?[indexPath.row] else { return UICollectionViewCell() }
        
        cell.config(unsplashPhoto: story)
        return cell
    }
}
