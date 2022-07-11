//
//  CompleteProfileCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-27.
//

import UIKit

class CompleteProfileCell: UITableViewCell {
    @IBOutlet weak var label1: ThemeBlackTextLabel!
    @IBOutlet var progressBars: [UIView]!
    @IBOutlet weak var totalRewardLabel: ThemeBlackTextLabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label2: ThemeBlackTextLabel!
    @IBOutlet weak var label3: ThemeGreyLabel!
    @IBOutlet weak var goalRewardLabel: ThemeBlackTextLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // reset all contents
        label1.text = ""
        for progressBar in progressBars {
            progressBar.backgroundColor = .lightGray
            progressBar.layer.cornerRadius = progressBar.frame.height / 2
        }
        totalRewardLabel.text = "0"
        iconImageView.image = nil
        label2.text = ""
        label3.text = ""
        goalRewardLabel.text = "0"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setLabel2AndLabel3(label2: String, label3: String) {
        if self.label2.text?.isEmpty ?? true {
            self.label2.text = label2
        }
        
        if self.label3.text?.isEmpty ?? true {
            self.label3.text = label3
        }
    }

    func config(all: [Goal], completed: [Goal], coinsRewardPerGoal: Int = 5) {
        var incompleteGoals: [Goal] = []
        var totalReward: Int = 0
        for goal in all {
            if !completed.contains(goal) {
                incompleteGoals.append(goal)
            }
            totalReward = totalReward + goal.reward
        }
        
        if let firstGoal = incompleteGoals.first {
            goalRewardLabel.text = "\(firstGoal.reward)"
            setLabel2AndLabel3(label2: "Add a gender!", label3: "Tell us your gender. ")
        } else {
            goalRewardLabel.text = "--"
            setLabel2AndLabel3(label2: "All goals complete!", label3: "")
        }
        totalRewardLabel.text = "\(totalReward)"
    }
}
