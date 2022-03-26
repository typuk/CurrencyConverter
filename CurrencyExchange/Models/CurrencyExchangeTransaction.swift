//
//  CurrencyExchangeTransaction.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 25/03/2022.
//

import Foundation

struct CurrencyExchangeTransaction: Equatable {
    let amount: Double
    let fromCurrency: Currency
    let toCurrency: Currency
}
