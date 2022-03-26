//
//  CurrencyExchangeResult.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 25/03/2022.
//

import Foundation

struct CurrencyExchangeResult {
    let amount: Double
    let convertedAmount: Double
    let conversionFee: Double
    let fromCurrency: Currency
    let toCurrency: Currency
}
