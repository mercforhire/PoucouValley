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
        if !data.itemName.isEmpty {
            itemName.text = data.itemName
        } else if let merchant = data.merchant {
            itemName.text = merchant.name
        }
        transactionType.text = data.itemType.capitalizingFirstLetter()
        transactionDate.text = DateUtil.convert(input: data.createdDate, outputFormat: .format12)
        
        var sign = ""
        if data.cost > 0 {
            sign = "+"
            amountLabel.textColor = .green
        } else {
            sign = ""
            amountLabel.textColor = themeManager.themeData!.textLabel.hexColor
        }
        amountLabel.text = "\(sign)\(data.cost)"
    }
}
