//
//  FollowUpClientCell.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-23.
//

import UIKit

class ClientCell: UITableViewCell {
    
    @IBOutlet weak var checkmarkContainer: UIView!
    @IBOutlet weak var checkmark: UIImageView!
    @IBOutlet weak var avatar: URLImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    var showCheck: Bool = false {
        didSet {
            checkmarkContainer.isHidden = !showCheck
        }
    }
    var checked: Bool = false {
        didSet {
            switch checked {
            case true:
                checkmark.image = UIImage(systemName: "checkmark.circle")
                contentView.backgroundColor = themeManager.themeData!.lighterGreen.hexColor
            case false:
                checkmark.image = UIImage(systemName: "circle")
                contentView.backgroundColor = .clear
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(client: Client) {
        if let thumbnailUrl = client.avatar?.thumbnailUrl {
            avatar.loadImageFromURL(urlString: thumbnailUrl)
        } else {
            avatar.image = UIImage.init(systemName: "person.fill")
        }
        nameLabel.text = client.fullName
        if let cardNumber = client.card, !cardNumber.isEmpty  {
            numberLabel.text = cardNumber
            numberLabel.isHidden = false
        } else {
            numberLabel.isHidden = true
        }
        showCheck = false
        checked = false
    }
}
