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
        let address = Address(unitNumber: unitField.text,
                              streetNumber: streetNumberField.text,
                              street: streetNameField.text,
                              city: cityField.text,
                              province: provinceField.text,
                              country: countryField.text,
                              postalCode: postalField.text)
        delegate?.setAddressCellAddressUpdated(address: address)
    }
}
