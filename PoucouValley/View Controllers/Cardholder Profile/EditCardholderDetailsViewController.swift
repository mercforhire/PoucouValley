//
//  EditCardholderDetailsViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-30.
//

import UIKit
import RealmSwift

class EditCardholderDetailsViewController: BaseViewController {
    
    @IBOutlet weak var interestsTableView: UITableView!
    @IBOutlet weak var interestsTableViewHeight: NSLayoutConstraint!

    @IBOutlet weak var areaCodeField: ThemeTextField!
    @IBOutlet weak var phoneNumberField: ThemeTextField!
    
    @IBOutlet weak var unitField: ThemeTextField!
    @IBOutlet weak var streetNumberField: ThemeTextField!
    @IBOutlet weak var streetNameField: ThemeTextField!
    @IBOutlet weak var cityField: ThemeTextField!
    @IBOutlet weak var provinceField: ThemeTextField!
    @IBOutlet weak var postalField: ThemeTextField!
    @IBOutlet weak var countryField: ThemeTextField!
    
    var selectedCategories: [BusinessCategories] = [] {
        didSet {
            interestsTableView.reloadData()
        }
    }
    
    private var contact: Contact? {
        didSet {
            guard let contact = contact else { return }
            
            areaCodeField.text = contact.phoneAreaCode
            phoneNumberField.text = contact.phoneNumber
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
    
    override func setup() {
        super.setup()
        
        navigationController?.isNavigationBarHidden = true

        interestsTableViewHeight.constant = CGFloat(50 * BusinessCategories.list().count)
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
            contact = Contact(email: nil, phoneAreaCode: nil, phoneNumber: nil, website: nil, twitter: nil, facebook: nil, instagram: nil)
        }
        
        if let address = currentUser.cardholder?.address {
            self.address = address
        } else {
            address = Address(unitNumber: nil, streetNumber: nil, street: nil, city: nil, province: nil, country: nil, postalCode: nil)
        }
        
        selectedCategories = currentUser.cardholder?.interests ?? []
    }

    @IBAction func updatePressed(_ sender: ThemeRoundedGreenBlackTextButton) {
        FullScreenSpinner().show()
        
        userManager.updateCardholderInfo(contact: contact, address: address, interests: selectedCategories) { [weak self] result in
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
        if textField == areaCodeField {
            phoneNumberField.becomeFirstResponder()
        } else if textField == phoneNumberField {
            textField.resignFirstResponder()
        } else if textField == unitField {
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
        if textField == areaCodeField {
            contact?.phoneAreaCode = textField.text
        } else if textField == phoneNumberField {
            contact?.phoneNumber = textField.text
        } else if textField == unitField {
            address?.unitNumber = textField.text
        } else if textField == streetNumberField {
            address?.streetNumber = textField.text
        } else if textField == streetNameField {
            address?.street = textField.text
        } else if textField == cityField {
            address?.city = textField.text
        } else if textField == provinceField {
            address?.province = textField.text
        } else if textField == postalField {
            address?.postalCode = textField.text
        } else if textField == countryField {
            address?.country = textField.text
        }
    }
}

extension EditCardholderDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BusinessCategories.list().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableCell", for: indexPath) as? ButtonTableCell else {
            return ButtonTableCell()
        }
        let type = BusinessCategories.list()[indexPath.row]
        cell.button.setTitle(type.rawValue, for: .normal)
        
        if selectedCategories.contains(type) {
            cell.button.addBorder(color: themeManager.themeData!.lighterGreen.hexColor)
        } else {
            cell.button.addBorder(color: .clear)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = BusinessCategories.list()[indexPath.row]
        
        if selectedCategories.contains(type),
            let index = selectedCategories.firstIndex(of: type) {
            selectedCategories.remove(at: index)
        } else {
            selectedCategories.append(type)
        }
    }
}
