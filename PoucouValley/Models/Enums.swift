//
//  Enums.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-14.
//

import Foundation

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
