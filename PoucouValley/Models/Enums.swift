//
//  Enums.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-14.
//

import Foundation
import AuthenticationServices

enum ResponseError: Error {
    case unknownError
    case userDoesNotExist
    case validationCodeInvalid
    case userAlreadyDeletedAccount
    case cardholderAlreadyExist
    case cardholderNotFound
    case cardPinIncorrect
    case emailAlreadyExist
    case merchantNotFound
    case cardAlreadyUsed
}

enum ResponseMessages: String, Codable {
    case userDoesNotExist = "USER_DOESNT_EXIST"
    case validationCodeInvalid = "VALIDATION_CODE_INVALID"
    case userAlreadyDeletedAccount = "USER_ALREADY_DELETED_ACCOUNT"
    case cardholderAlreadyExist = "CARDHOLDER_ALREADY_EXIST"
    case cardholderNotFound = "CARDHOLDER_NOT_FOUND"
    case cardPinIncorrect = "CARD_PIN_INCORRECT"
    case emailAlreadyExist = "EMAIL_ALREADY_EXIST"
    case merchantNotFound = "MERCHANT_NOT_FOUND"
    case cardAlreadyUsed = "CARD_ALREADY_USED"
    
    func toError() -> Error {
        switch self {
        case .userDoesNotExist:
            return ResponseError.userDoesNotExist
        case .validationCodeInvalid:
            return ResponseError.validationCodeInvalid
        case .userAlreadyDeletedAccount:
            return ResponseError.userAlreadyDeletedAccount
        case .cardholderAlreadyExist:
            return ResponseError.cardholderAlreadyExist
        case .cardholderNotFound:
            return ResponseError.cardholderNotFound
        case .cardPinIncorrect:
            return ResponseError.cardPinIncorrect
        case .emailAlreadyExist:
            return ResponseError.emailAlreadyExist
        case .merchantNotFound:
            return ResponseError.merchantNotFound
        case .cardAlreadyUsed:
            return ResponseError.cardAlreadyUsed
        }
    }
    
    func errorMessage() -> String {
        switch self {
        case .userDoesNotExist:
            return "Account with this email doesn't exist."
        case .validationCodeInvalid:
            return "Validation code is invalid."
        case .userAlreadyDeletedAccount:
            return "Account with this email has been deleted."
        case .cardholderAlreadyExist:
            return "Cardholder for this card already exist."
        case .cardholderNotFound:
            return "Cardholder not found."
        case .cardPinIncorrect:
            return "Card pin is incorrect."
        case .emailAlreadyExist:
            return "Account with this email already exist."
        case .merchantNotFound:
            return "Merchant not found."
        case .cardAlreadyUsed:
            return "Card already registered to another cardholder."
        }
    }
}

enum UserType: String, Codable {
    case cardholder
    case merchant
}

extension UserType {
    init(from decoder: Decoder) throws {
        self = try UserType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .cardholder
    }
}


enum Genders: String, Codable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    func pronoun() -> String {
        switch self {
        case .male:
            return "He"
        case .female:
            return "She"
        case .other:
            return "Zhe"
        }
    }
}

enum ClientGroupTypes: Int {
    case activated
    case followed
    case inputted
    case scanned

    static func getRows() -> [ClientGroupTypes] {
        return [.activated, .followed, .inputted, .scanned]
    }
    
    func title() -> String {
        switch self {
        case .activated:
            return "Activated Users"
        case .followed:
            return "Followers"
        case .inputted:
            return "Inputted Users"
        case .scanned:
            return "Scanned Users"
        }
    }
}

/*
 [
    {
       "_id":{
          "$oid":"62702a4c3d95e39c8df54b92"
       },
       "type":"Sports",
       "order":{
          "$numberInt":"0"
       }
    },
    {
       "_id":{
          "$oid":"62702a113d95e39c8df54b90"
       },
       "type":"Food",
       "order":{
          "$numberInt":"1"
       }
    },
    {
       "_id":{
          "$oid":"62702a5a3d95e39c8df54b93"
       },
       "type":"Clothes",
       "order":{
          "$numberInt":"2"
       }
    },
    {
       "_id":{
          "$oid":"62702a653d95e39c8df54b94"
       },
       "type":"Pets",
       "order":{
          "$numberInt":"3"
       }
    },
    {
       "_id":{
          "$oid":"62702a713d95e39c8df54b95"
       },
       "type":"Fun",
       "order":{
          "$numberInt":"4"
       }
    },
    {
       "_id":{
          "$oid":"62702a783d95e39c8df54b96"
       },
       "type":"Finance",
       "order":{
          "$numberInt":"5"
       }
    },
    {
       "_id":{
          "$oid":"62e2d994d1053c065401d158"
       },
       "type":"Gifts",
       "order":{
          "$numberInt":"6"
       }
    },
    {
       "_id":{
          "$oid":"62e2d9f3d1053c065401d159"
       },
       "type":"Other",
       "order":{
          "$numberInt":"7"
       }
    }
 ]
 */
enum BusinessCategories: String, Codable {
    case sports = "Sports"
    case food = "Food"
    case clothes = "Clothes"
    case pets = "Pets"
    case fun = "Fun"
    case finance = "Finance"
    case gifts = "Gifts"
    case other = "Other"
    
    static func list() -> [BusinessCategories] {
        return [.sports, .food, .clothes, .pets, .fun, .finance, .gifts, .other]
    }
    
    func iconName() -> String {
        switch self {
        case .sports:
            return "Icon-gym"
        case .food:
            return "Icon-food"
        case .clothes :
            return "Icon-clothing-store"
        case .pets:
            return "Icon-dog"
        case .fun:
            return "Icon-hat-wizard"
        case .finance:
            return "Icon-money-bill"
        case .gifts:
            return "Icon-gifts"
        case .other:
            return "Icon-flower"
        }
    }
}

extension BusinessCategories {
    init(from decoder: Decoder) throws {
        self = try BusinessCategories(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .other
    }
}
