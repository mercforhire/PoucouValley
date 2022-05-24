//
//  LoginViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-19.
//

import UIKit

class LoginViewController: BaseViewController {
    var mode: UserType!

    @IBOutlet weak var cardholderLabel: ThemeBlackTextLabel!
    @IBOutlet weak var businessLabel: ThemeBlackTextLabel!
    
    @IBOutlet weak var emailField: ThemeTextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var loginButton: ThemeRoundedGreenBlackTextButton!
    
    @IBOutlet weak var signInWithScanContainer: UIView!
    @IBOutlet weak var scanButton: ThemeRoundedGreenBlackTextButton!
    
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
        navigationController?.navigationBar.isHidden = true
        
        switch mode {
        case .cardholder:
            cardholderLabel.isHidden = false
            businessLabel.isHidden = true
            signInWithScanContainer.isHidden = false
            scanButton.isHidden = false
        case .merchant:
            cardholderLabel.isHidden = true
            businessLabel.isHidden = false
            signInWithScanContainer.isHidden = true
            scanButton.isHidden = true
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
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if validate(), let email = emailField.text {
            FullScreenSpinner().show()
            api.checkLoginEmail(email: email) { [weak self] result in
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.selectedEmail = email
                        self?.performSegue(withIdentifier: "goToEnterCode", sender: self)
                    } else {
                        showErrorDialog(error: ResponseMessages.userDoesNotExist.errorMessage())
                    }
                case .failure(let error):
                    showNetworkErrorDialog()
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LoginEnterCodeViewController {
            vc.email = selectedEmail
            vc.mode = mode
        }
    }
}

extension LoginViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            loginPressed(loginButton)
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
