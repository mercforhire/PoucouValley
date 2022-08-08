//
//  HashTagsTableViewCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-07.
//

import UIKit

class HashTagsTableViewCell: UITableViewCell {
    
    var tags: [String] = []
    var showPlusButton: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    private let kCellHeight: CGFloat = 37
    private let kItemPadding = 12
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10
        bubbleLayout.minimumInteritemSpacing = 5
        bubbleLayout.delegate = self
        collectionView.setCollectionViewLayout(bubbleLayout, animated: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(tags: [String], showPlusButton: Bool, finishAction: Action?) {
        self.tags = tags
        self.showPlusButton = showPlusButton
        collectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            finishAction?()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
    }
}

extension HashTagsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
        let tag = tags[indexPath.row]
        cell.lblTitle.text = tag
        cell.addBorder(color: .lightGray)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension HashTagsTableViewCell: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        if indexPath.row < tags.count {
            let interest = tags[indexPath.row]
            var size = interest.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: 17.0)!])
            size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
            size.height = kCellHeight
            
            //...Checking if item width is greater than collection view width then set item width == collection view width.
            if size.width > collectionView.frame.size.width {
                size.width = collectionView.frame.size.width
            }
            
            return size
        } else {
            return CGSize.init(width: kCellHeight, height: kCellHeight)
        }
    }
}
