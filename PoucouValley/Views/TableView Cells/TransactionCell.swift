//
//  TransactionCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-30.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var itemName: ThemeBlackTextLabel!
    @IBOutlet weak var transactionType: ThemeBlackTextLabel!
    @IBOutlet weak var transactionDate: ThemeBlackTextLabel!
    @IBOutlet weak var amountLabel: ThemeBlackTextLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: Transaction) {
        itemName.text = data.itemName
        transactionType.text = data.itemType.capitalizingFirstLetter()
        transactionDate.text = DateUtil.convert(input: data.createdDate, outputFormat: .format12)
        
        var sign = ""
        switch data.itemType {
        case "redeem":
            sign = "-"
            amountLabel.textColor = .red
        case "reward":
            sign = "+"
            amountLabel.textColor = .green
        default:
            sign = "-"
            amountLabel.textColor = themeManager.themeData!.textLabel.hexColor
        }
        amountLabel.text = "\(sign)\(data.cost)"
    }
}
