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
        label2.text = ""
        goalRewardLabel.text = "0"
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for progressBar in progressBars {
            progressBar.backgroundColor = .lightGray
            progressBar.layer.cornerRadius = progressBar.frame.height / 2
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(all: [Goal], completed: [Goal]) {
        var incompleteGoals: [Goal] = []
        var totalReward: Int = 0
        for goal in all {
            if !completed.contains(where: { $0.goal == goal.goal }) {
                incompleteGoals.append(goal)
            }
            totalReward = totalReward + goal.reward
        }
        
        let greenProgressBars = progressBars.filter { view in
            return view.tag < completed.count
        }
        for bar in greenProgressBars {
            bar.backgroundColor = themeManager.themeData?.lighterGreen.hexColor
        }
        
        if let incompleteGoal = incompleteGoals.first {
            goalRewardLabel.text = "\(incompleteGoal.reward)"
            label2.text = incompleteGoal.goal
        } else {
            goalRewardLabel.text = "--"
            label2.text = "All goals complete!"
        }
        totalRewardLabel.text = "\(totalReward)"
    }
}
