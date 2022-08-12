//
//  SignUpEnterCodeViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-21.
//

import UIKit

class SignUpEnterCodeViewController: BaseViewController {
    var email: String!
    var mode: UserType!
    
    @IBOutlet weak var code1Field: ThemeTextField!
    @IBOutlet weak var code2Field: ThemeTextField!
    @IBOutlet weak var code3Field: ThemeTextField!
    @IBOutlet weak var code4Field: ThemeTextField!
    @IBOutlet weak var codeErrorLabel: UILabel!
    @IBOutlet weak var registerButton: ThemeRoundedGreenBlackTextButton!
    
    var codeString: String? {
        didSet {
            if let codeString = codeString, !codeString.isEmpty {
                codeErrorLabel.text = codeString
                codeErrorLabel.isHidden = false
            } else {
                codeErrorLabel.text = ""
                codeErrorLabel.isHidden = true
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        codeString = nil
        code1Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code2Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code3Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code4Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
        if (code1Field.text ?? "").isEmpty || (code2Field.text ?? "").isEmpty || (code3Field.text ?? "").isEmpty || (code4Field.text ?? "").isEmpty {
            codeString = "* Code not filled"
            return false
        } else {
            codeString = ""
        }
        
        return true
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if validate() {
            FullScreenSpinner().show()
            let code = "\(code1Field.text ?? "")\(code2Field.text ?? "")\(code3Field.text ?? "")\(code4Field.text ?? "")"
            userManager.register(email: email, code: code, userType: mode) { [weak self] success in
                FullScreenSpinner().hide()
                
                if success {
                    self?.userManager.proceedPastLogin()
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
            code4Field.becomeFirstResponder()
            if (textfield.text ?? "").isEmpty {
                code2Field.becomeFirstResponder()
            } else {
                code4Field.becomeFirstResponder()
            }
        } else if textfield == code4Field {
            if (textfield.text ?? "").isEmpty {
                code3Field.becomeFirstResponder()
            }
        }
    }
}


extension SignUpEnterCodeViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == code1Field {
            code2Field.becomeFirstResponder()
        } else if textField == code2Field {
            code3Field.becomeFirstResponder()
        } else if textField == code3Field {
            code4Field.becomeFirstResponder()
        } else if textField == code4Field {
            code4Field.resignFirstResponder()
            registerPressed(registerButton)
        }
        
        return true
    }
}
