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
                return [.name, .email, .category]
            case .merchant:
                return [.name, .category]
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
    
    @IBOutlet weak var tableView: UITableView!
    
    private var stepNumber: Int = 0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        
        if let cardholder = userManager.user?.cardholder {
            if userManager.user?.user?.email.isEmpty ?? true {
                mode = .cardholderOnly
            } else {
                mode = .cardholderWithEmail
            }
        } else if let merchant = userManager.user?.merchant {
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
            tableCell = cell
        case "SetupEmailCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupEmailCell else {
                return SetupEmailCell()
            }
            tableCell = cell
        case "SetupInterestsCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupInterestsCell else {
                return SetupInterestsCell()
            }
            tableCell = cell
        case "SetupShopNameCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupShopNameCell else {
                return SetupShopNameCell()
            }
            tableCell = cell
        case "SetupBusinessFieldCell":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? SetupBusinessFieldCell else {
                return SetupBusinessFieldCell()
            }
            tableCell = cell
        default:
            tableCell = UITableViewCell()
        }
        
        return tableCell
    }
}
