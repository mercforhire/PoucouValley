//
//  GetStartedCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit

class GetStartedCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(data: GetStartedSteps) {
        iconImageView.image = UIImage(named: data.image)
        
        var count = 0
        for text in data.text {
            switch count {
            case 0:
                label1.text = text
            case 1:
                label2.text = text
            case 2:
                label3.text = text
            case 3:
                label4.text = text
            case 4:
                label5.text = text
            default:
                break
            }
            count += 1
        }
    }
}
