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
                heButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                sheButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                theyButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            case "She":
                heButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                sheButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                theyButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            case "They":
                heButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                sheButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                theyButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            default:
                heButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                sheButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                theyButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
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
            heButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            sheButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            theyButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
        } else if data.pronoun == "She" {
            heButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            sheButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            theyButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
        } else if data.pronoun == "They" {
            heButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            sheButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            theyButton.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: themeManager.themeData!.textLabel.hexColor)
        } else {
            heButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            sheButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
            theyButton.unhighlightButton(back: themeManager.themeData!.whiteBackground.hexColor, text: themeManager.themeData!.textLabel.hexColor)
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
