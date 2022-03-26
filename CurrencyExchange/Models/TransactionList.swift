//
//  TransactionList.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 23/03/2022.
//

import Foundation

struct TransactionList: Codable {
    var transactions: [Currency: Int]
    
    var totalTransactionCount: Int {
        transactions.values.reduce(0, +)
    }
    
    mutating func increaseTransactionCount(for currency: Currency) {
        let transactionCount = transactions[currency] ?? 0
        transactions[currency] = (transactionCount + 1)
    }
}
