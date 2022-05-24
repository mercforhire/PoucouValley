//
//  SignUpEnterEmailViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-23.
//

import UIKit

class SignUpEnterEmailViewController: BaseViewController {
    var cardNumber: String!
    var cardPin: String!
    
    @IBOutlet weak var emailField: ThemeTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var signUpButton: ThemeRoundedGreenBlackTextButton!
    
    private var emailErrorString: String? {
        didSet {
            if let emailErrorString = emailErrorString,
                !emailErrorString.isEmpty {
                emailErrorLabel.text = emailErrorString
                emailErrorLabel.isHidden = false
            } else {
                emailErrorLabel.text = ""
                emailErrorLabel.isHidden = true
            }
        }
    }
    
    override func setup() {
        super.setup()
        emailErrorString = nil
        navigationController?.navigationBar.isHidden = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailField.text = appSettings.getLastUsedEmail()
    }

    private func validate() -> Bool {
        if (emailField.text ?? "").isEmpty {
            emailErrorString = "* Email is empty"
            return false
        } else if let email = emailField.text, !Validator.validate(string: email, validation: .email) {
            emailErrorString = "* Invalid email"
            return false
        } else {
            emailErrorString = ""
        }
        
        return true
    }

    @IBAction func signUpPressed(_ sender: UIButton) {
        if validate(), let email = emailField.text {
            FullScreenSpinner().show()
            userManager.register(cardNumber: cardNumber, code: cardPin, email: email) { [weak self] success in
                FullScreenSpinner().hide()
                
                if success {
                    self?.userManager.proceedPastLogin()
                }
            }
        }
    }
}


extension SignUpEnterEmailViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            signUpPressed(signUpButton)
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
