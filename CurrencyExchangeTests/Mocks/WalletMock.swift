//
//  File.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 23/03/2022.
//

import Foundation
import Combine
@testable import CurrencyExchange

final class WalletMock: Wallet {
    
    var availableBalancesMockData: [CurrencyBalance] = []
    var deposits = [[String: Double]]()
    var withdraws = [[String: Double]]()
    let availableBalancesSubject = CurrentValueSubject<[CurrencyBalance], Never>([])
    
    var availableBalances: AnyPublisher<[CurrencyBalance], Never> {
        availableBalancesSubject.eraseToAnyPublisher()
    }
    
    func balance(for currency: Currency) throws -> Double {
        availableBalancesMockData.first(where: { $0.currency == currency })?.amount ?? 0
    }
    
    func makeDeposit(currency: String, amount: Double) throws {
        deposits.append([currency: amount])
    }
    
    func makeWithdraw(currency: String, amount: Double) throws {
        withdraws.append([currency: amount])
    }
}
