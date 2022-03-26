//
//  Wallet.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 21/03/2022.
//

import Foundation
import Combine

struct CurrencyBalance: Codable, Hashable {
    var currency: Currency
    var amount: Double
}

protocol Wallet {
    func makeDeposit(currency: String, amount: Double) throws
    func makeWithdraw(currency: String, amount: Double) throws
    
    func balance(for currency: Currency) throws -> Double
    
    var availableBalances: AnyPublisher<[CurrencyBalance], Never> { get }
}

class WalletService: Wallet {
    
    private let availableBalancesSubject: CurrentValueSubject<[CurrencyBalance], Never>
    private let storage: Storage
    
    var availableBalances: AnyPublisher<[CurrencyBalance], Never> {
        availableBalancesSubject.eraseToAnyPublisher()
    }
    
    init(storage: Storage) {
        
        self.storage = storage
        
        if let currencyBalance = storage.currencyBalance() {
            availableBalancesSubject = CurrentValueSubject(currencyBalance)
        } else {
            let currencyBalance = [CurrencyBalance(currency: Constants.balanceInitialCurrency, amount: Constants.balanceInitialAmount)]
            storage.saveCurrencyBalance(currencyBalance)
            availableBalancesSubject = CurrentValueSubject(currencyBalance)
        }
    }
    
    func balance(for currency: Currency) throws -> Double {
        guard let amount = availableBalancesSubject.value.first(where: { $0.currency == currency })?.amount else {
            throw CurrencyExchangeErrors.currencyNotFound
        }
        
        return amount
    }
    
    func makeDeposit(currency: String, amount: Double) throws {
        var balances = availableBalancesSubject.value
        if let index = balances.firstIndex(where: { $0.currency == currency }) {
            var currencyBalance = balances[index]
            currencyBalance.amount += amount
            balances.remove(at: index)
            balances.append(currencyBalance)
        } else {
            balances.append(CurrencyBalance(currency: currency, amount: amount))
        }
        storage.saveCurrencyBalance(balances)
        availableBalancesSubject.send(balances)
    }
    
    func makeWithdraw(currency: String, amount: Double) throws {
        var balances = availableBalancesSubject.value
        guard let selectedCurrencyIndex = balances.firstIndex(where: { $0.currency == currency }) else {
            throw CurrencyExchangeErrors.currencyNotFound
        }
        
        var selectedCurrency = balances[selectedCurrencyIndex]
        
        guard selectedCurrency.amount >= amount else {
            throw CurrencyExchangeErrors.notEnoughBalance
        }
        
        selectedCurrency.amount -= amount
        balances[selectedCurrencyIndex] = selectedCurrency
        storage.saveCurrencyBalance(balances)
        availableBalancesSubject.send(balances)
    }
}
