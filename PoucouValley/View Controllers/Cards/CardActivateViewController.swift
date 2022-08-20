//
//  CardActivateViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-25.
//

import UIKit

class CardActivateViewController: BaseViewController {
    var scannedCardNumber: String?
    
    @IBOutlet weak var cardNumber1Field: ThemeTextField!
    @IBOutlet weak var cardNumber2Field: ThemeTextField!
    @IBOutlet weak var cardNumber3Field: ThemeTextField!
    @IBOutlet weak var cardNumberErrorLabel: UILabel!
    var cardNumberErrorString: String? {
        didSet {
            if let cardNumberErrorString = cardNumberErrorString, !cardNumberErrorString.isEmpty {
                cardNumberErrorLabel.text = cardNumberErrorString
            } else {
                cardNumberErrorLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var code1Field: ThemeTextField!
    @IBOutlet weak var code2Field: ThemeTextField!
    @IBOutlet weak var code3Field: ThemeTextField!
    @IBOutlet weak var codeErrorLabel: UILabel!
    var codeErrorString: String? {
        didSet {
            if let codeErrorString = codeErrorString, !codeErrorString.isEmpty {
                codeErrorLabel.text = codeErrorString
            } else {
                codeErrorLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var submitButton: ThemeRoundedGreenBlackTextButton!
    
    override func setup() {
        super.setup()
        
        cardNumberErrorString = nil
        codeErrorString = nil
        
        cardNumber1Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cardNumber2Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cardNumber3Field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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
        disectScannedCardNumber()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    private func disectScannedCardNumber() {
        guard let scannedCardNumber = scannedCardNumber else { return }
        
        let elements = scannedCardNumber.split(separator: "-")
        
        for i in 0..<elements.count {
            switch i {
            case 0:
                cardNumber1Field.text = String(elements[i])
            case 1:
                cardNumber2Field.text = String(elements[i])
            case 2:
                cardNumber3Field.text = String(elements[i])
            default:
                break
            }
        }
    }
    
    private func validate(step1Only: Bool = false) -> Bool {
        if (cardNumber1Field.text ?? "").isEmpty || (cardNumber2Field.text ?? "").isEmpty || (cardNumber3Field.text ?? "").isEmpty {
            cardNumberErrorString = "* Card number not filled"
            return false
        } else {
            cardNumberErrorString = ""
        }
        
        
        if (code1Field.text ?? "").isEmpty || (code2Field.text ?? "").isEmpty || (code3Field.text ?? "").isEmpty {
            codeErrorString = "* Code not filled"
            return false
        } else {
            codeErrorString = ""
        }
        
        return true
    }
    
    @IBAction private func donePressed(_ sender: UIButton) {
        if validate() {
            let cardNumber = "\(cardNumber1Field.text ?? "")-\(cardNumber2Field.text ?? "")-\(cardNumber3Field.text ?? "")"
            let pin = "\(code1Field.text ?? "")\(code2Field.text ?? "")\(code3Field.text ?? "")"
            
            FullScreenSpinner().show()
            api.addCardToCardholder(cardNumber: cardNumber, pin: pin, callBack: { [weak self] result in
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if response.success {
                        self?.goToSuccessScreen()
                    } else if response.message == ResponseMessages.cardholderNotFound.rawValue {
                        self?.cardNumberErrorString = ResponseMessages.cardholderNotFound.errorMessage()
                    } else if response.message == ResponseMessages.cardAlreadyUsed.rawValue {
                        self?.cardNumberErrorString = ResponseMessages.cardAlreadyUsed.errorMessage()
                    } else if response.message == ResponseMessages.cardPinIncorrect.rawValue {
                        self?.codeErrorString = ResponseMessages.cardPinIncorrect.errorMessage()
                    } else {
                        self?.cardNumberErrorString = "Unknown error"
                    }
                case .failure:
                    showNetworkErrorDialog()
                }
            })
        }
    }
    
    private func goToSuccessScreen() {
        userManager.fetchUser(completion: { [weak self] _ in
            self?.performSegue(withIdentifier: "goToActivateSuccess", sender: self)
        })
    }
    
    @objc private func textFieldDidChange(_ textfield: UITextField) {
        if textfield == cardNumber1Field {
            if (textfield.text ?? "").isEmpty {
                
            } else {
                cardNumber2Field.becomeFirstResponder()
            }
        } else if textfield == cardNumber2Field {
            if (textfield.text ?? "").isEmpty {
                code1Field.becomeFirstResponder()
            } else if (textfield.text ?? "").count == 6 {
                code3Field.becomeFirstResponder()
            }
        } else if textfield == cardNumber3Field {
            if (textfield.text ?? "").isEmpty {
                cardNumber2Field.becomeFirstResponder()
            }
        }
        
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
    
}


extension CardActivateViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cardNumber1Field {
            cardNumber2Field.becomeFirstResponder()
        } else if textField == cardNumber2Field {
            cardNumber3Field.becomeFirstResponder()
        } else if textField == cardNumber3Field {
            code1Field.becomeFirstResponder()
        }
        
        else if textField == code1Field {
            code2Field.becomeFirstResponder()
        } else if textField == code2Field {
            code3Field.becomeFirstResponder()
        } else if textField == code3Field {
            code3Field.resignFirstResponder()
            donePressed(submitButton)
        }
        
        return true
    }
}

