//
//  ImageAndLabelCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-10.
//

import UIKit

class ImageAndLabelNormalCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unhighlight()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unhighlight()
    }
    
    func config(data: BusinessCategories) {
        iconImageView.image = UIImage(named: data.iconName())
        label.text = data.rawValue.capitalizingFirstLetter()
    }
    
    func highlight() {
        contentView.backgroundColor = themeManager.themeData!.lighterGreen.hexColor
        iconImageView.tintColor = .white
        label.textColor = .white
    }
    
    func unhighlight() {
        contentView.backgroundColor = .white
        iconImageView.tintColor = .black
        label.textColor = .black
    }
}
