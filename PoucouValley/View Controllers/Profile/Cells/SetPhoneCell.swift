//
//  SetPhoneCell.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-27.
//

import UIKit

protocol SetPhoneCellDelegate: class {
    func setPhoneCellPhoneUpdated(contact: Contact)
}

class SetPhoneCell: UITableViewCell {

    @IBOutlet weak var areaCodeField: ThemeTextField!
    @IBOutlet weak var phoneField: ThemeTextField!
    
    weak var delegate: SetPhoneCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        areaCodeField.delegate = self
        phoneField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: Contact?) {
        guard let data = data else {
            areaCodeField.text = nil
            phoneField.text = nil
            return
        }
        
        areaCodeField.text = data.phoneAreaCode
        phoneField.text = data.phoneNumber
    }
}

extension SetPhoneCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == areaCodeField {
            phoneField.becomeFirstResponder()
        } else if textField == phoneField {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let contact = Contact(phoneAreaCode: areaCodeField.text, phoneNumber: phoneField.text, website: nil, twitter: nil, facebook: nil, instagram: nil)
        delegate?.setPhoneCellPhoneUpdated(contact: contact)
    }
}
