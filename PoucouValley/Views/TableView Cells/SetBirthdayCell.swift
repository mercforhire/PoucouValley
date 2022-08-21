//
//  SetBirthdayCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-27.
//

import UIKit

protocol SetBirthdayCellDelegate: class {
    func setBirthdayCellUpdated(birthday: Birthday?)
}

class SetBirthdayCell: UITableViewCell {
    private enum EditingMode {
        case month
        case day
        case year
    }

    @IBOutlet weak var monthButton: ThemeBlackButton!
    @IBOutlet weak var dayButton: ThemeBlackButton!
    @IBOutlet weak var yearButton: ThemeBlackButton!
    @IBOutlet weak var divider: UIView!
    
    @IBOutlet weak var monthContainer: UIView!
    @IBOutlet var monthButtons: [ThemeGreyButton]!
    
    @IBOutlet weak var dayContainer: UIView!
    @IBOutlet var dayButtons: [ThemeGreyButton]!
    
    @IBOutlet weak var yearContainer: UIView!
    @IBOutlet weak var yearUpButton: UIButton!
    @IBOutlet var yearsButtons: [ThemeGreyButton]!
    @IBOutlet weak var yearDownButton: ThemeGreyButton!
    
    private var editingMode: EditingMode? {
        didSet {
            switch editingMode {
            case .month:
                divider.isHidden = false
                monthButton.setTitleColor(themeManager.themeData!.lighterGreen.hexColor, for: .normal)
                dayButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
                yearButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
                
                self.monthContainer.isHidden = false
                self.dayContainer.isHidden = true
                self.yearContainer.isHidden = true
            case .day:
                divider.isHidden = false
                monthButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
                dayButton.setTitleColor(themeManager.themeData!.lighterGreen.hexColor, for: .normal)
                yearButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
                
                self.monthContainer.isHidden = true
                self.dayContainer.isHidden = false
                self.yearContainer.isHidden = true
            case .year:
                divider.isHidden = false
                monthButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
                dayButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
                yearButton.setTitleColor(themeManager.themeData!.lighterGreen.hexColor, for: .normal)
                
                self.monthContainer.isHidden = true
                self.dayContainer.isHidden = true
                self.yearContainer.isHidden = false
            default:
                divider.isHidden = true
                monthButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
                dayButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
                yearButton.setTitleColor(themeManager.themeData!.textLabel.hexColor, for: .normal)
                
                self.monthContainer.isHidden = true
                self.dayContainer.isHidden = true
                self.yearContainer.isHidden = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: Notifications.RequestTableViewUpdate, object: nil)
            }
        }
    }
    
    private var selectedMonthButtonTag: Int? {
        didSet {
            for button in monthButtons {
                if button.tag == selectedMonthButtonTag {
                    button.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                } else {
                    button.unhighlightButton(back: .clear, text: themeManager.themeData!.textLabel.hexColor)
                }
            }
            
            if let selectedMonthButtonTag = selectedMonthButtonTag {
                monthButton.setTitle("\(selectedMonthButtonTag + 1)", for: .normal)
                getDate()
            } else {
                monthButton.setTitle("MM", for: .normal)
            }
        }
    }
    private var selectedDayButtonTag: Int? {
        didSet {
            for button in dayButtons {
                if button.tag == selectedDayButtonTag {
                    button.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                } else {
                    button.unhighlightButton(back: .clear, text: themeManager.themeData!.textLabel.hexColor)
                }
            }
            
            if let selectedDayButtonTag = selectedDayButtonTag {
                dayButton.setTitle("\(selectedDayButtonTag + 1)", for: .normal)
                getDate()
            } else {
                dayButton.setTitle("DD", for: .normal)
            }
        }
    }
    private var selectedYearButtonTag: Int? {
        didSet {
            for button in yearsButtons {
                if button.tag == selectedYearButtonTag {
                    button.highlightButton(back: themeManager.themeData!.lighterGreen.hexColor, text: themeManager.themeData!.textLabel.hexColor)
                } else {
                    button.unhighlightButton(back: .clear, text: themeManager.themeData!.textLabel.hexColor)
                }
            }
            
            if let selectedYearButtonTag = selectedYearButtonTag {
                let selectYearButton = getYearButton(nth: selectedYearButtonTag)
                yearButton.setTitle(selectYearButton?.titleLabel?.text, for: .normal)
                getDate()
            } else {
                yearButton.setTitle("YYYY", for: .normal)
            }
        }
    }
    
    private let totalNumberOfButtons = 25
    private var mostRecentYear = Date().year() {
        didSet {
            refreshYearButtons()
        }
    }
    
    weak var delegate: SetBirthdayCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        refreshYearButtons()
        editingMode = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: Birthday?) {
        guard let data = data else {
            selectedDayButtonTag = nil
            selectedMonthButtonTag = nil
            selectedYearButtonTag = nil
            return
        }
        
        selectedDayButtonTag = data.day - 1
        selectedMonthButtonTag = data.month - 1
        yearButton.setTitle("\(data.year)", for: .normal)
        
        while data.year < (mostRecentYear - totalNumberOfButtons) {
            yearUpPressed(yearUpButton as! ThemeGreyButton)
        }
        highlightYearButton(year: data.year)
    }
    
    private func getDate() {
        guard let selectedDayButtonTag = selectedDayButtonTag,
                let selectedYearButtonTag = selectedYearButtonTag,
              let year = getYearButton(nth: selectedYearButtonTag)?.titleLabel?.text?.int,
                let selectedMonthButtonTag = selectedMonthButtonTag,
                let _ = Date.makeDate(year: year, month: selectedMonthButtonTag + 1, day: selectedDayButtonTag + 1)
        else {
            return
        }
        
        let birthday = Birthday(day: selectedDayButtonTag + 1, month: selectedMonthButtonTag + 1, year: year)
        delegate?.setBirthdayCellUpdated(birthday: birthday)
    }
    
    private func refreshYearButtons() {
        for i in 0..<totalNumberOfButtons {
            let yearButton = getYearButton(nth: i)
            yearButton?.setTitle("\(mostRecentYear - (totalNumberOfButtons - i))", for: .normal)
        }
    }
    
    private func highlightYearButton(year: Int) {
        for button in yearsButtons {
            if button.titleLabel?.text == "\(year)" {
                selectedYearButtonTag = button.tag
            }
        }
    }
    
    private func getMonthsButton(nth: Int) -> UIButton? {
        for button in monthButtons {
            if button.tag == nth {
                return button
            }
        }
        
        return nil
    }
    
    private func getDaysButton(nth: Int) -> UIButton? {
        for button in dayButtons {
            if button.tag == nth {
                return button
            }
        }
        
        return nil
    }
    
    private func getYearButton(nth: Int) -> UIButton? {
        for button in yearsButtons {
            if button.tag == nth {
                return button
            }
        }
        
        return nil
    }
    
    @IBAction private func monthPressed(_ sender: ThemeBlackButton) {
        if editingMode == .month {
            editingMode = nil
        } else {
            editingMode = .month
        }
    }
    
    @IBAction private func dayPressed(_ sender: ThemeBlackButton) {
        if editingMode == .day {
            editingMode = nil
        } else {
            editingMode = .day
        }
    }
    
    @IBAction private func yearPressed(_ sender: ThemeBlackButton) {
        if editingMode == .year {
            editingMode = nil
        } else {
            editingMode = .year
        }
    }
    
    @IBAction private func monthSelectionPressed(_ sender: ThemeGreyButton) {
        let month = sender.tag
        
        if selectedMonthButtonTag == month {
            selectedMonthButtonTag = nil
        } else {
            selectedMonthButtonTag = month
        }
    }
    
    @IBAction private func daySelectionPressed(_ sender: ThemeGreyButton) {
        let day = sender.tag
        
        if selectedDayButtonTag == day {
            selectedDayButtonTag = nil
        } else {
            selectedDayButtonTag = day
        }
    }
    
    @IBAction private func yearSelectionPressed(_ sender: ThemeGreyButton) {
        let year = sender.tag
        
        if selectedYearButtonTag == year {
            selectedYearButtonTag = nil
        } else {
            selectedYearButtonTag = year
        }
    }
    
    @IBAction private func yearUpPressed(_ sender: ThemeGreyButton) {
        mostRecentYear = mostRecentYear - totalNumberOfButtons
    }
    
    @IBAction private func yearDownPressed(_ sender: ThemeGreyButton) {
        guard mostRecentYear < Date().year() else { return }
        
        mostRecentYear = mostRecentYear + totalNumberOfButtons
    }
}
