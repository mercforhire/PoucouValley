//
//  UserDetails.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class UserDetails: BaseObject {
    var user: User?
    var cardholder: Cardholder?
    var merchant: Merchant?
    
    convenience init(document: Document) {
        self.init()
        self.user = User(document: document["user"]!!.documentValue!)
        if let document = document["cardholder"]??.documentValue {
            self.cardholder = Cardholder(document: document)
        }
        if let document = document["merchant"]??.documentValue {
            self.merchant = Merchant(document: document)
        }
    }
    
    func isProfileComplete() -> Bool {
        guard let user = user else { return false }
        
        switch user.userType {
        case .cardholder:
            return !(cardholder?.firstName?.isEmpty ?? true)
        case .merchant:
            return !(merchant?.name?.isEmpty ?? true)
        }
    }
    
    func toUpdateCardholderInfoParams() -> UpdateCardholderInfoParams? {
        guard let cardholder = cardholder, let user = user else {
            return nil
        }
        
        var params = UpdateCardholderInfoParams(firstName: cardholder.firstName, lastName: cardholder.lastName, pronoun: cardholder.pronoun, gender: cardholder.gender, birthday: cardholder.birthday, contact: cardholder.contact, address: cardholder.address, avatar: cardholder.avatar, interests: nil)
        return params
    }
}
