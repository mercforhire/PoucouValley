//
//  SetupInitialProfileViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-22.
//

import UIKit

class SetupInitialProfileViewController: BaseViewController {
    enum SetupCardholderSteps: Int {
        case name
        case businessName
        case category
        case businessCategory
        
        static func rows(mode: UserType) -> [SetupCardholderSteps] {
            switch mode {
            case .cardholder:
                return [.name, .category]
            case .merchant:
                return [.businessName, .businessCategory]
            }
        }
        
        func cellName() -> String {
            switch self {
            case .name:
                return "SetupPersonNameCell"
            case .businessName:
                return "SetupShopNameCell"
            case .category:
                return "SetupInterestsCell"
            case .businessCategory:
                return "SetupBusinessFieldCell"
            }
        }
    }
    
    private var businessTypes: [BusinessCategories] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // cardholder
    private var firstName: String?
    private var lastName: String?
    private var interests: [BusinessCategories] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    //merchant
    private var businessName: String?
    private var businessField: BusinessCategories? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let FirstNameTag = 1
    private let LastNameTag = 2
    private let BusinessNameTag = 3
    
    @IBOutlet weak var tableView: UITableView!
    
    private var stepNumber: Int = 0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        
        navigationController?.viewControllers = [self]
        stepNumber = 0
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        businessTypes = BusinessCategories.list()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func logOffPressed(_ sender: UIBarButtonItem) {
        userManager.logout()
    }
    
    @objc func donePressed(_ sender: UIButton) {
        view.endEditing(true)
        
        if !validateCurrentStep() {
            showErrorDialog(error: "Please enter all information.")
            return
        }
        let step = SetupCardholderSteps.rows(mode: currentUser.user!.userType)[stepNumber]
        
        if step == SetupCardholderSteps.rows(mode: currentUser.user!.userType).last {
            switch currentUser.user!.userType {
            case .cardholder:
                userManager.updateCardholderInfo(firstName: firstName, lastName: lastName, pronoun: nil, gender: nil, birthday: nil, contact: nil, address: nil, avatar: nil, interests: interests) { [weak self] result in
                    switch result {
                    case .success:
                        self?.userManager.proceedPastLogin()
                    case .failure:
                        break
                    }
                }
            case .merchant:
                userManager.updateMerchantInfo(name: businessName, field: businessField, logo: nil, photos: nil, contact: nil, address: nil, cards: nil) { [weak self]  result in
                    switch result {
                    case .success:
                        self?.userManager.proceedPastLogin()
                    case .failure:
                        break
                    }
                }
            }
        } else {
            stepNumber = stepNumber + 1
        }
    }
    
    private func validateCurrentStep() -> Bool {
        let step = SetupCardholderSteps.rows(mode: currentUser.user!.userType)[stepNumber]
        switch step {
        case .name:
            guard let firstName = firstName, let lastName = lastName else { return false }
            
            return Validator.validate(string: firstName, validation: .isAProperName) &&
                Validator.validate(string: lastName, validation: .containsOneAlpha)
            
        case .businessName:
            guard let businessName = businessName else { return false }
            
            return Validator.validate(string: businessName, validation: .isAProperName)
            
        case .category:
            return !interests.isEmpty
            
        case .businessCategory:
            return businessField != nil
        }
    }
}

extension SetupInitialProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellName = SetupCardholderSteps.rows(mode: currentUser.user!.userType)[stepNumber].cellName()
        var tableCell: UITableViewCell!
        
        switch cellName {
        case "SetupPersonNameCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupPersonNameCell else {
                return SetupPersonNameCell()
            }
            cell.firstNameField.tag = FirstNameTag
            cell.lastNameField.tag = LastNameTag
            cell.firstNameField.delegate = self
            cell.lastNameField.delegate = self
            cell.submitButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
            tableCell = cell
        case "SetupInterestsCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupInterestsCell else {
                return SetupInterestsCell()
            }
            cell.config(data: businessTypes, selected: interests)
            cell.submitButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
            cell.delegate = self
            tableCell = cell
        case "SetupShopNameCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupShopNameCell else {
                return SetupShopNameCell()
            }
            cell.nameField.tag = BusinessNameTag
            cell.nameField.delegate = self
            cell.submitButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
            tableCell = cell
        case "SetupBusinessFieldCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupBusinessFieldCell else {
                return SetupBusinessFieldCell()
            }
            cell.config(data: businessTypes, selectedType: businessField)
            cell.submitButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
            cell.delegate = self
            tableCell = cell
        default:
            tableCell = UITableViewCell()
        }
        
        return tableCell
    }
}

extension SetupInitialProfileViewController: SetupInterestsCellDelegate {
    func selectedInterests(interests: [BusinessCategories]) {
        self.interests = interests
    }
}

extension SetupInitialProfileViewController: SetupBusinessCellDelegate {
    func selectedBusinessType(type: BusinessCategories) {
        businessField = type
    }
}

extension SetupInitialProfileViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == FirstNameTag {
            firstName = textField.text
        } else if textField.tag == LastNameTag {
            lastName = textField.text
        } else if textField.tag == BusinessNameTag {
            businessName = textField.text
        }
    }
}
