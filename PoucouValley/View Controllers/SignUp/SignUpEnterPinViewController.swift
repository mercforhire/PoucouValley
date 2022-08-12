//
//  SignUpEnterPinViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-23.
//

import UIKit

class SignUpEnterPinViewController: BaseViewController {
    var cardNumber: String!
    
    @IBOutlet weak var code1Field: ThemeTextField!
    @IBOutlet weak var code2Field: ThemeTextField!
    @IBOutlet weak var code3Field: ThemeTextField!
    @IBOutlet weak var codeErrorLabel: UILabel!
    @IBOutlet weak var signUpButton: ThemeRoundedGreenBlackTextButton!
    
    private var codeString: String? {
        didSet {
            if let codeString = codeString, !codeString.isEmpty {
                codeErrorLabel.text = codeString
            } else {
                codeErrorLabel.text = ""
            }
        }
    }
    
    private var pin: String {
        return "\(code1Field.text ?? "")\(code2Field.text ?? "")\(code3Field.text ?? "")"
    }
    
    override func setup() {
        super.setup()
        
        codeString = nil
        code1Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code2Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code3Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
        
        navigationController?.isNavigationBarHidden = true
    }
    
    private func validate(step1Only: Bool = false) -> Bool {
        if (code1Field.text ?? "").isEmpty || (code2Field.text ?? "").isEmpty || (code3Field.text ?? "").isEmpty {
            codeString = "* Code not filled"
            return false
        } else {
            codeString = ""
        }
        
        return true
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        if validate() {
            FullScreenSpinner().show()
            
            api.checkCardAvailable(cardNumber: cardNumber, code: pin) { [weak self] result in
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.performSegue(withIdentifier: "goToEnterEmail", sender: self)
                    } else if response.message == ResponseMessages.cardPinIncorrect.rawValue {
                        showErrorDialog(error: ResponseMessages.cardPinIncorrect.errorMessage())
                    } else if response.message == ResponseMessages.cardholderAlreadyExist.rawValue {
                        showErrorDialog(error: ResponseMessages.cardholderAlreadyExist.errorMessage())
                    } else if response.message == ResponseMessages.cardNotExist.rawValue {
                        showErrorDialog(error: ResponseMessages.cardNotExist.errorMessage())
                    } else {
                        showErrorDialog(error: "Unknown error")
                    }
                case .failure:
                    showNetworkErrorDialog()
                }
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        if textfield == code1Field {
            if (textfield.text ?? "").isEmpty {
                
            } else {
                code2Field.becomeFirstResponder()
            }
        } else if textfield == code2Field {
            if (textfield.text ?? "").isEmpty {
                code1Field.becomeFirstResponder()
            } else {
                code3Field.becomeFirstResponder()
            }
        } else if textfield == code3Field {
            if (textfield.text ?? "").isEmpty {
                code3Field.becomeFirstResponder()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpEnterEmailViewController {
            vc.cardNumber = cardNumber
            vc.cardPin = pin
        }
    }
}

extension SignUpEnterPinViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == code1Field {
            code2Field.becomeFirstResponder()
        } else if textField == code2Field {
            code3Field.becomeFirstResponder()
        } else if textField == code3Field {
            code3Field.resignFirstResponder()
            nextPressed(signUpButton)
        }
        
        return true
    }
}
