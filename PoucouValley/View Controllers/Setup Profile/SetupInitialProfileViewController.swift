//
//  SetupInitialProfileViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-22.
//

import UIKit

enum SetupProfileModes {
    case cardholderOnly
    case cardholderWithEmail
    case merchant
}

class SetupInitialProfileViewController: BaseViewController {
    enum SetupCardholderSteps: Int {
        case name
        case businessName
        case email
        case category
        case businessCategory
        
        static func rows(mode: SetupProfileModes) -> [SetupCardholderSteps] {
            switch mode {
            case .cardholderOnly:
                return [.name, .category]
            case .cardholderWithEmail:
                return [.name, .category]
            case .merchant:
                return [.email, .name, .category]
            }
        }
        
        func cellName() -> String {
            switch self {
            case .name:
                return "SetupPersonNameCell"
            case .businessName:
                return "SetupBusinessFieldCell"
            case .email:
                return "SetupEmailCell"
            case .category:
                return "SetupInterestsCell"
            case .businessCategory:
                return "SetupBusinessFieldCell"
            }
        }
    }
    
    private var mode: SetupProfileModes = .cardholderOnly
    private var businessTypes: [BusinessType] = []
    private var selectedBusinessTypes: BusinessType?
    
    private let FirstNameTag = 1
    private let LastNameTag = 2
    private let EmailTag = 3
    private let BusinessNameTag = 4
    
    @IBOutlet weak var tableView: UITableView!
    
    private var stepNumber: Int = 0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        
        if let _ = userManager.user?.cardholder {
            if userManager.user?.user?.email.isEmpty ?? true {
                mode = .cardholderOnly
            } else {
                mode = .cardholderWithEmail
            }
        } else if let _ = userManager.user?.merchant {
            mode = .merchant
        }
        
        navigationController?.navigationBar.isHidden = true
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
        api.fetchBusinessTypes { [weak self] result in
            switch result {
            case .success(let response):
                self?.businessTypes = Array(response.data)
            case .failure(let error):
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        if !validateCurrentStep() {
            return
        }
        
        stepNumber = stepNumber + 1
    }
    
    private func validateCurrentStep() -> Bool {
        let step = SetupCardholderSteps.rows(mode: mode)[stepNumber]
        switch step {
        case .name:
            break
        case .businessName:
            break
        case .email:
            break
        case .category:
            break
        case .businessCategory:
            break
        }
        return true
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
        let cellName = SetupCardholderSteps.rows(mode: mode)[stepNumber].cellName()
        
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
        case "SetupEmailCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupEmailCell else {
                return SetupEmailCell()
            }
            cell.emailField.tag = EmailTag
            cell.emailField.delegate = self
            cell.submitButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
            tableCell = cell
        case "SetupInterestsCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupInterestsCell else {
                return SetupInterestsCell()
            }
            cell.config(data: businessTypes, selectedType: selectedBusinessTypes)
            cell.submitButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
            tableCell = cell
        case "SetupShopNameCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupShopNameCell else {
                return SetupShopNameCell()
            }
            cell.nameField.tag = BusinessNameTag
            cell.submitButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
            tableCell = cell
        case "SetupBusinessFieldCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupBusinessFieldCell else {
                return SetupBusinessFieldCell()
            }
            cell.config(data: businessTypes, selectedType: selectedBusinessTypes)
            cell.submitButton.addTarget(self, action: #selector(donePressed), for: .touchUpInside)
            tableCell = cell
        default:
            tableCell = UITableViewCell()
        }
        
        return tableCell
    }
}

extension SetupInitialProfileViewController: UITextFieldDelegate {
   func textFieldDidBeginEditing(_ textField: UITextField) {
       if textField.tag == FirstNameTag {
           
       } else if textField.tag == LastNameTag {
           
       } else if textField.tag == EmailTag {
           
       } else if textField.tag == BusinessNameTag {
           
       }
   }
}
