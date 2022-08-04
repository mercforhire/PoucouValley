//
//  SetAddressCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-27.
//

import UIKit

protocol SetAddressCellDelegate: class {
    func setAddressCellAddressUpdated(address: Address)
}

class SetAddressCell: UITableViewCell {

    @IBOutlet weak var unitField: ThemeTextField!
    @IBOutlet weak var streetNumberField: ThemeTextField!
    @IBOutlet weak var streetNameField: ThemeTextField!
    @IBOutlet weak var cityField: ThemeTextField!
    @IBOutlet weak var provinceField: ThemeTextField!
    @IBOutlet weak var postalField: ThemeTextField!
    @IBOutlet weak var countryField: ThemeTextField!
    
    weak var delegate: SetAddressCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        unitField.delegate = self
        streetNumberField.delegate = self
        streetNameField.delegate = self
        cityField.delegate = self
        provinceField.delegate = self
        postalField.delegate = self
        countryField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: Address?) {
        guard let data = data else {
            unitField.text = nil
            streetNumberField.text = nil
            streetNameField.text = nil
            cityField.text = nil
            provinceField.text = nil
            postalField.text = nil
            countryField.text = nil
            return
        }
        
        unitField.text = data.unitNumber
        streetNumberField.text = data.streetNumber
        streetNameField.text = data.street
        cityField.text = data.city
        provinceField.text = data.province
        postalField.text = data.postalCode
        countryField.text = data.country
    }

}

extension SetAddressCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        if textField == unitField {
            textField.text = textField.text?.capitalized
        } else if textField == streetNumberField {
            textField.text = textField.text?.capitalized
        } else if textField == streetNameField {
            textField.text = textField.text?.capitalized
        } else if textField == cityField {
            textField.text = textField.text?.capitalized
        } else if textField == provinceField {
            textField.text = textField.text?.capitalized
        } else if textField == postalField {
            textField.text = textField.text?.capitalized
        } else if textField == countryField {
            textField.text = textField.text?.capitalized
        }
        
        let address = Address(unitNumber: unitField.text?.capitalized,
                              streetNumber: streetNumberField.text?.capitalized,
                              street: streetNameField.text?.capitalized,
                              city: cityField.text?.capitalized,
                              province: provinceField.text?.capitalized,
                              country: countryField.text?.capitalized,
                              postalCode: postalField.text?.capitalized)
        delegate?.setAddressCellAddressUpdated(address: address)
    }
}
