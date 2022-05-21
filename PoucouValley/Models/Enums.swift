//
//  Enums.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-14.
//

import Foundation

enum ResponseMessages: String, Codable {
    case userDoesNotExist = "USER_DOESNT_EXIST"
    case validationCodeInvalid = "VALIDATION_CODE_INVALID"
    case userAlreadyDeletedAccount = "USER_ALREADY_DELETED_ACCOUNT"
    case cardholdAlreadyExist = "CARDHOLDER_ALREADY_EXIST"
    case cardholderNotFound = "CARDHOLDER_NOT_FOUND"
    case cardPinIncorrect = "CARD_PIN_INCORRECT"
    case emailAlreadyExist = "EMAIL_ALREADY_EXIST"
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
