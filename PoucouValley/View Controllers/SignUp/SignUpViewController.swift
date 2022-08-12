//
//  SignUpViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-21.
//

import UIKit

class SignUpViewController: BaseViewController {
    var mode: UserType!
    
    @IBOutlet weak var cardholderLabel: ThemeBlackTextLabel!
    @IBOutlet weak var businessLabel: ThemeBlackTextLabel!
    
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
    private var selectedEmail: String?
    
    override func setup() {
        super.setup()
        emailErrorString = nil
        
        switch mode {
        case .cardholder:
            cardholderLabel.isHidden = false
            businessLabel.isHidden = true
        case .merchant:
            cardholderLabel.isHidden = true
            businessLabel.isHidden = false
        default:
            break
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
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
            api.checkRegisterEmail(email: email) { [weak self] result in
                switch result {
                case .success(let response):
                    if response.success {
                        self?.proceed(email: email)
                    } else {
                        FullScreenSpinner().hide()
                        showErrorDialog(error: ResponseMessages.emailAlreadyExist.errorMessage())
                    }
                case .failure:
                    FullScreenSpinner().hide()
                    showNetworkErrorDialog()
                }
            }
        }
    }
    
    private func proceed(email: String) {
        api.sendEmailCode(email: email) { [weak self] result in
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if response.success {
                    self?.selectedEmail = email
                    self?.performSegue(withIdentifier: "goToEnterCode", sender: self)
                } else {
                    showErrorDialog(error: response.message ?? "")
                }
            case .failure:
                showNetworkErrorDialog()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpEnterCodeViewController {
            vc.email = selectedEmail
            vc.mode = mode
        }
    }

}

extension SignUpViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            signUpPressed(signUpButton)
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
