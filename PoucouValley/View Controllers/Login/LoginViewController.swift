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
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if validate(), let email = emailField.text {
            FullScreenSpinner().show()
            api.checkLoginEmail(email: email) { [weak self] result in
                switch result {
                case .success(let response):
                    if response.success {
                        self?.proceed(email: email)
                    } else {
                        FullScreenSpinner().hide()
                        showErrorDialog(error: ResponseMessages.userDoesNotExist.errorMessage())
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
        if let vc = segue.destination as? LoginEnterCodeViewController {
            vc.email = selectedEmail
            vc.mode = mode
        }
    }
    
    private var tappedNumber: Int = 0 {
        didSet {
            if tappedNumber >= 10 {
                let ac = UIAlertController(title: nil, message: "Choose environment", preferredStyle: .actionSheet)
                let action1 = UIAlertAction(title: "Production\(AppSettingsManager.shared.getEnvironment() == .production ? "(Selected)" : "")", style: .default) { [weak self] action in
                    self?.userManager.setEnvironment(environments: .production, completion: { [weak self] success in
                        success ? self?.clearFields() : nil
                    })
                }
                ac.addAction(action1)
                
                let action2 = UIAlertAction(title: "Development\(AppSettingsManager.shared.getEnvironment() == .development ? "(Selected)" : "")", style: .default) { [weak self] action in
                    self?.userManager.setEnvironment(environments: .development, completion: { [weak self] success in
                        success ? self?.clearFields() : nil
                    })
                }
                ac.addAction(action2)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                    self?.tappedNumber = 0
                }
                ac.addAction(cancelAction)
                present(ac, animated: true)
            }
        }
    }
    
    @IBAction func cheatButtonPress(_ sender: UIButton) {
        print("CheatButton Pressed")
        tappedNumber = tappedNumber + 1
    }
    
    private func clearFields() {
        UserManager.shared.clearSavedInformation()
        tappedNumber = 0
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
