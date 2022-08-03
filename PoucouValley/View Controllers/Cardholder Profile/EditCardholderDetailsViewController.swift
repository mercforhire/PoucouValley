//
//  EditCardholderDetailsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-30.
//

import UIKit
import PhoneNumberKit
import RealmSwift

class EditCardholderDetailsViewController: BaseViewController {

    @IBOutlet weak var phoneNumberField: PhoneNumberTextField!
    
    @IBOutlet weak var unitField: ThemeTextField!
    @IBOutlet weak var streetNumberField: ThemeTextField!
    @IBOutlet weak var streetNameField: ThemeTextField!
    @IBOutlet weak var cityField: ThemeTextField!
    @IBOutlet weak var provinceField: ThemeTextField!
    @IBOutlet weak var postalField: ThemeTextField!
    @IBOutlet weak var countryField: ThemeTextField!
    
    private var contact: Contact? {
        didSet {
            guard let contact = contact,
                  let phoneNumber = try? phoneNumberKit.parse("\(contact.phoneAreaCode ?? "")\(contact.phoneNumber ?? "")") else { return }
            
            phoneNumberField.text = phoneNumberKit.format(phoneNumber, toType: .national, withPrefix: true)
        }
    }
    
    private var address: Address? {
        didSet {
            unitField.text = address?.unitNumber
            streetNumberField.text = address?.streetNumber
            streetNameField.text = address?.street
            cityField.text = address?.city
            provinceField.text = address?.province
            postalField.text = address?.postalCode
            countryField.text = address?.country
        }
    }
    
    private let phoneNumberKit = PhoneNumberKit()
    
    override func setup() {
        super.setup()
        
        navigationController?.navigationBar.isHidden = true
        PhoneNumberKit.CountryCodePicker.commonCountryCodes = ["US", "CA"]
        phoneNumberField.withFlag = true
        phoneNumberField.withPrefix = true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
    }
    
    func loadData() {
        if let contact = currentUser.cardholder?.contact {
            self.contact = contact
        } else {
            contact = Contact(email: nil, phoneAreaCode: "", phoneNumber: "", website: nil, twitter: nil, facebook: nil, instagram: nil)
        }
        
        if let address = currentUser.cardholder?.address {
            self.address = address
        } else {
            address = Address(unitNumber: "", streetNumber: "", street: "", city: "", province: "", country: "", postalCode: "")
        }
    }

    @IBAction func updatePressed(_ sender: ThemeRoundedGreenBlackTextButton) {
        FullScreenSpinner().show()
        
        userManager.updateCardholderInfo(contact: contact, address: address) { [weak self] result in
            FullScreenSpinner().hide()
            
            switch result {
            case .success:
                self?.loadData()
                self?.navigationController?.popViewController(animated: true)
            case .failure:
                break
            }
        }
    }
}

extension EditCardholderDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneNumberField {
            textField.resignFirstResponder()
        }
        if textField == unitField {
            streetNumberField.becomeFirstResponder()
        } else if textField == streetNumberField {
            streetNameField.becomeFirstResponder()
        } else if textField == streetNameField {
            cityField.becomeFirstResponder()
        } else if textField == cityField {
            provinceField.becomeFirstResponder()
        } else if textField == provinceField {
            postalField.becomeFirstResponder()
        } else if textField == postalField {
            countryField.becomeFirstResponder()
        } else if textField == countryField {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phoneNumberField {
            guard let phoneNumber = try? phoneNumberKit.parse(textField.text ?? "") else { return }
            
            contact?.phoneAreaCode = "\(phoneNumber.countryCode)"
            contact?.phoneNumber = "\(phoneNumber.nationalNumber)"
        } else if textField == unitField {
            address?.unitNumber = textField.text?.capitalized
        } else if textField == streetNumberField {
            address?.streetNumber = textField.text?.capitalized
        } else if textField == streetNameField {
            address?.street = textField.text?.capitalized
        } else if textField == cityField {
            address?.city = textField.text?.capitalized
        } else if textField == provinceField {
            address?.province = textField.text?.capitalized
        } else if textField == postalField {
            address?.postalCode = textField.text?.capitalized
        } else if textField == countryField {
            address?.country = textField.text?.capitalized
        }
    }
}
