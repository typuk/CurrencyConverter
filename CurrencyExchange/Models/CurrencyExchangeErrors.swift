//
//  CurrencyExchangeErrors.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 25/03/2022.
//

import Foundation

enum CurrencyExchangeErrors: Error, LocalizedError {
    case exchangeRateNotFound
    case notEnoughBalance
    case currencyNotFound
    
    var errorDescription: String? {
        switch self {
        case .exchangeRateNotFound:
            return "Exchange rate not found"
        case .notEnoughBalance:
            return "Not enough funds"
        case .currencyNotFound:
            return "Currency not found"
        }
    }
}
