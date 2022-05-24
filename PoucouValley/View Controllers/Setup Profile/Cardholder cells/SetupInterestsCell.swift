//
//  SetupInterestsCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-22.
//

import UIKit

protocol SetupInterestsCellDelegate: class {
    func selectedInterest(type: BusinessType)
}

class SetupInterestsCell: UITableViewCell {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var submitButton: ThemeRoundedGreenBlackTextButton!
    
    var data: [BusinessType] = []
    var selectedType: BusinessType?
    weak var delegate: SetupInterestsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: [BusinessType], selectedType: BusinessType?) {
        self.data = data
        self.selectedType = selectedType
        tableView.reloadData()
        tableViewHeight.constant = CGFloat(50 * data.count)
    }
}

extension SetupInterestsCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableCell", for: indexPath) as? ButtonTableCell else {
            return ButtonTableCell()
        }
        let type = data[indexPath.row]
        cell.button.setTitle(type.type, for: .normal)
        if type.type == selectedType?.type {
            cell.button.addBorder(color: themeManager.themeData!.lighterGreen.hexColor)
        } else {
            cell.button.addBorder(color: .clear)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = data[indexPath.row]
        delegate?.selectedInterest(type: type)
    }
}
