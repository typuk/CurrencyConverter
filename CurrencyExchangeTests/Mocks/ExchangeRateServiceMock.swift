//
//  ExchangeRateServiceMock.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 25/03/2022.
//

import Foundation
@testable import CurrencyExchange

final class ExchangeRateServiceMock: ExchangeRateService {
    
    func updateExchnageRates(with model: CurrencyExchangeModel) {
        
    }
    
    func convertCurrency(for transaction: CurrencyExchangeTransaction) throws -> CurrencyExchangeResult {
        return CurrencyExchangeResult(amount: 0,
                                      convertedAmount: transaction.amount,
                                      conversionFee: 0,
                                      fromCurrency: transaction.fromCurrency,
                                      toCurrency: transaction.toCurrency)
    }
    
    func calculateTransactionAmount(for transaction: CurrencyExchangeTransaction) throws -> Double {
        return 0
    }
    
    func calculateTransactionFee(for transaction: CurrencyExchangeTransaction) throws -> Double {
        return 0
    }
    
}
