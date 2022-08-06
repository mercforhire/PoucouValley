//
//  EnterClientCardNumberViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-21.
//

import UIKit

class EnterClientCardNumberViewController: BaseViewController {

    @IBOutlet weak var code1Field: ThemeTextField!
    @IBOutlet weak var code2Field: ThemeTextField!
    @IBOutlet weak var code3Field: ThemeTextField!
    @IBOutlet weak var codeErrorLabel: UILabel!
    @IBOutlet weak var submitButton: ThemeRoundedGreenBlackTextButton!
    
    var codeString: String? {
        didSet {
            if let codeString = codeString, !codeString.isEmpty {
                codeErrorLabel.text = codeString
            } else {
                codeErrorLabel.text = ""
            }
        }
    }
    
    var cardNumber: String {
        return "\(code1Field.text ?? "")\(code2Field.text ?? "")\(code3Field.text ?? "")"
    }
    
    override func setup() {
        super.setup()
        
        codeString = nil
        navigationController?.navigationBar.isHidden = true
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

    private func validate(step1Only: Bool = false) -> Bool {
        if (code1Field.text ?? "").isEmpty || (code2Field.text ?? "").isEmpty || (code3Field.text ?? "").isEmpty {
            codeString = "* Code not filled"
            return false
        } else {
            codeString = ""
        }
        
        return true
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        if validate() {
            FullScreenSpinner().show()
            
            api.scanCard(cardNumber: cardNumber) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self.showCardScannedDialog()
                    } else {
                        showErrorDialog(error: response.message)
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
    
    private func showCardScannedDialog() {
        let dialog = PictureTextDialog()
        let dialogImage = UIImage(named: "creditcard")
        let config = PictureTextDialogConfig(image: dialogImage, primaryLabel: "Poncou card successfully scanned!", secondLabel: "")
        dialog.configure(config: config, showDimOverlay: true, overUIWindow: true)
        dialog.delegate = self
        dialog.show(inView: view, withDelay: 100)
    }
}

extension EnterClientCardNumberViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == code1Field {
            code2Field.becomeFirstResponder()
        } else if textField == code2Field {
            code3Field.becomeFirstResponder()
        } else if textField == code3Field {
            code3Field.resignFirstResponder()
            submitPressed(submitButton)
        }
        
        return true
    }
}

extension EnterClientCardNumberViewController: PictureTextDialogDelegate {
    func dismissedDialog(dialog: PictureTextDialog) {
        navigationController?.popToRootViewController(animated: true)
    }
}
