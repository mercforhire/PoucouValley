//
//  SetGendersCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-27.
//

import UIKit

protocol SetGendersCellDelegate: class {
    func setGendersCellUpdated(gender: String?)
}

class SetGendersCell: UITableViewCell {

    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    
    private var gender: String? {
        didSet {
            switch gender {
            case "Male":
                maleButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
                femaleButton.unhighlightButton()
                otherButton.unhighlightButton()
            case "Female":
                maleButton.unhighlightButton()
                femaleButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
                otherButton.unhighlightButton()
            case "Other":
                maleButton.unhighlightButton()
                femaleButton.unhighlightButton()
                otherButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
            default:
                maleButton.unhighlightButton()
                femaleButton.unhighlightButton()
                otherButton.unhighlightButton()
            }
            delegate?.setGendersCellUpdated(gender: gender)
        }
    }
    
    weak var delegate: SetGendersCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        maleButton.roundCorners(style: .small)
        femaleButton.roundCorners(style: .small)
        otherButton.roundCorners(style: .small)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: Cardholder) {
        if data.gender == "Male" {
            maleButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
            femaleButton.unhighlightButton()
            otherButton.unhighlightButton()
        } else if data.gender == "Female" {
            maleButton.unhighlightButton()
            femaleButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
            otherButton.unhighlightButton()
        } else if data.gender == "Other" {
            maleButton.unhighlightButton()
            femaleButton.unhighlightButton()
            otherButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
        } else {
            maleButton.unhighlightButton()
            femaleButton.unhighlightButton()
            otherButton.unhighlightButton()
        }
    }

    @IBAction func malePressed(_ sender: UIButton) {
        gender = "Male"
    }
    
    @IBAction func femalePressed(_ sender: UIButton) {
        gender = "Female"
    }
    
    @IBAction func otherPressed(_ sender: UIButton) {
        gender = "Other"
    }
}
