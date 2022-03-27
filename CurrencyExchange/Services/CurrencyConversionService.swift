//
//  ExchangeRateService.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 21/03/2022.
//

import Foundation
import SwiftUI

protocol CurrencyConversionService {
    func updateExchnageRates(with model: CurrencyExchangeModel)
    func convertCurrency(for transaction: CurrencyExchangeTransaction) throws -> CurrencyExchangeResult
    
    func calculateTransactionAmount(for transaction: CurrencyExchangeTransaction) throws -> Double
    func calculateTransactionFee(for transaction: CurrencyExchangeTransaction) throws -> Double
}

class CurrencyExchangeRateServiceImplementation: CurrencyConversionService {
    
    private var baseCurrency: Currency
    private let storage: Storage
    private let wallet: Wallet
    
    private var exchangeRates = [CurrencyExchangeRate]()
    
    private let queue = DispatchQueue(label: "ExchangeRateService")
    
    init(baseCurrency: Currency = .euro, storage: Storage, wallet: Wallet) {
        self.baseCurrency = baseCurrency
        self.storage = storage
        self.wallet = wallet
    }
    
    func updateExchnageRates(with model: CurrencyExchangeModel) {
        queue.sync {
            self.baseCurrency = model.base
            self.exchangeRates = model.rates
        }
    }
    
    func convertCurrency(for transaction: CurrencyExchangeTransaction) throws -> CurrencyExchangeResult {
        try queue.sync {
            try convert(for: transaction)
        }
    }
    
    func calculateTransactionAmount(for transaction: CurrencyExchangeTransaction) throws -> Double {
        try queue.sync {
            try amount(for: transaction)
        }
    }
    
    func calculateTransactionFee(for transaction: CurrencyExchangeTransaction) throws -> Double {
        try queue.sync {
            try fee(for: transaction)
        }
    }
}

private extension CurrencyExchangeRateServiceImplementation {
    
    var todaysTransactionList: TransactionList {
        let todaysDateString = Date().dateString
        if let transactionList = storage.transactionList(for: todaysDateString) {
            return transactionList
        } else {
            let transactionList = TransactionList(transactions: [:])
            storage.saveTransactionList(transactionList, date: todaysDateString)
            return transactionList
        }
    }
    
    func addCurrencyToTransactionList(_ currency: Currency) {
        var todaysTransactionList = todaysTransactionList
        todaysTransactionList.increaseTransactionCount(for: currency)
        storage.saveTransactionList(todaysTransactionList, date: Date().dateString)
    }
    
    func calculateAmountToBaseCurrency(for transaction: CurrencyExchangeTransaction) throws -> Double {
        guard let exchangeRate = exchangeRates.first(where: { $0.currency == transaction.fromCurrency }) else {
            throw CurrencyExchangeErrors.exchangeRateNotFound
        }
        
        return transaction.amount / exchangeRate.exchangeRate
    }
    
    func convert(for transaction: CurrencyExchangeTransaction) throws -> CurrencyExchangeResult {
        let amountToConvert = try amount(for: transaction)
        let fee = try fee(for: transaction)
        let currencyBalance = try wallet.balance(for: transaction.fromCurrency)
        
        guard currencyBalance >= (transaction.amount + fee) else {
            throw CurrencyExchangeErrors.notEnoughBalance
        }
        
        try wallet.makeWithdraw(currency: transaction.fromCurrency, amount: transaction.amount)
        try wallet.makeDeposit(currency: transaction.toCurrency, amount: amountToConvert)
        try wallet.makeWithdraw(currency: transaction.fromCurrency, amount: fee)
        
        addCurrencyToTransactionList(transaction.fromCurrency)
        
        return CurrencyExchangeResult(amount: transaction.amount,
                                      convertedAmount: amountToConvert,
                                      conversionFee: fee,
                                      fromCurrency: transaction.fromCurrency,
                                      toCurrency: transaction.toCurrency)
    }
    
    func fee(for transaction: CurrencyExchangeTransaction) throws -> Double {
        let numberOfTransactionTodayForCurrency = todaysTransactionList.transactionCount(for: transaction.fromCurrency)
        let numberOfTotalTransaction = todaysTransactionList.totalTransactionCount
        
        let additionalFee: Double
        if transaction.fromCurrency != baseCurrency {
            let transaction = CurrencyExchangeTransaction(amount: 0.3, fromCurrency: .euro, toCurrency: transaction.fromCurrency)
            additionalFee = try amount(for: transaction)
        } else {
            additionalFee = 0.3
        }
        
        let input = FeeRule.Input(numberOfTransactionsForToday: numberOfTransactionTodayForCurrency,
                                  numberOfTotalTransactionForToday: numberOfTotalTransaction,
                                  additionalFee: additionalFee,
                                  amount: transaction.amount)
        
        return FeeRule.allRules.map {
            $0.evaluate(input)
        }.reduce(0, +)
    }
    
    func amount(for transaction: CurrencyExchangeTransaction) throws -> Double {
        guard let exchangeRate = exchangeRates.first(where: { $0.currency == transaction.toCurrency }) else {
            throw CurrencyExchangeErrors.exchangeRateNotFound
        }
        
        let baseCurrencyAmount: Double
        if transaction.fromCurrency != baseCurrency {
            baseCurrencyAmount = try calculateAmountToBaseCurrency(for: transaction)
        } else {
            baseCurrencyAmount = transaction.amount
        }
        
        return baseCurrencyAmount * exchangeRate.exchangeRate
    }
}

private extension TransactionList {
    func transactionCount(for currency: Currency) -> Int {
        transactions.first(where: { $0.key == currency })?.value ?? 0
    }
}
