//
//  StorageMock.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 23/03/2022.
//

import Foundation
@testable import CurrencyExchange

final class StorageMock: Storage {
    
    var transactionListMockData: TransactionList?
    var currencyBalanceMockData: [CurrencyBalance]?
    
    func saveTransactionList(_ transactionList: TransactionList, date: String) {
        transactionListMockData = transactionList
    }
    
    func transactionList(for date: String) -> TransactionList? {
        transactionListMockData
    }
    
    func saveCurrencyBalance(_ currencyBalance: [CurrencyBalance]) {
        currencyBalanceMockData = currencyBalance
    }
    
    func currencyBalance() -> [CurrencyBalance]? {
        currencyBalanceMockData
    }
}
