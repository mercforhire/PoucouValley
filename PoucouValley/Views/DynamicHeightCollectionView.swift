//
//  DynamicHeightCollectionView.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-19.
//

import UIKit

class DynamicHeightCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.size != intrinsicContentSize {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
}
