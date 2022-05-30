//
//  SetPronounsCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-27.
//

import UIKit

protocol SetPronounsCellDelegate: class {
    func setPronounsCellUpdated(pronoun: String?)
}

class SetPronounsCell: UITableViewCell {

    @IBOutlet weak var heButton: UIButton!
    @IBOutlet weak var sheButton: UIButton!
    @IBOutlet weak var theyButton: UIButton!
    
    private var pronoun: String? {
        didSet {
            switch pronoun {
            case "He":
                heButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
                sheButton.unhighlightButton()
                theyButton.unhighlightButton()
            case "She":
                heButton.unhighlightButton()
                sheButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
                theyButton.unhighlightButton()
            case "They":
                heButton.unhighlightButton()
                sheButton.unhighlightButton()
                theyButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
            default:
                heButton.unhighlightButton()
                sheButton.unhighlightButton()
                theyButton.unhighlightButton()
            }
            delegate?.setPronounsCellUpdated(pronoun: pronoun)
        }
    }
    
    weak var delegate: SetPronounsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        heButton.roundCorners(style: .small)
        sheButton.roundCorners(style: .small)
        theyButton.roundCorners(style: .small)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: Cardholder) {
        if data.pronoun == "He" {
            heButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
            sheButton.unhighlightButton()
            theyButton.unhighlightButton()
        } else if data.pronoun == "She" {
            heButton.unhighlightButton()
            sheButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
            theyButton.unhighlightButton()
        } else if data.pronoun == "They" {
            heButton.unhighlightButton()
            sheButton.unhighlightButton()
            theyButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: .black)
        } else {
            heButton.unhighlightButton()
            sheButton.unhighlightButton()
            theyButton.unhighlightButton()
        }
        pronoun = data.pronoun
    }
    
    @IBAction func hePressed(_ sender: UIButton) {
        pronoun = "He"
    }
    
    @IBAction func shePressed(_ sender: UIButton) {
        pronoun = "She"
    }
    
    @IBAction func theyPressed(_ sender: UIButton) {
        pronoun = "They"
    }
}
