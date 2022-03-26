//
//  CurrencyExchangeTests.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 19/03/2022.
//

import XCTest
@testable import CurrencyExchange

class FeeRulesTests: XCTestCase {

    func testFirstFiveTransactionsForFree() throws {
        let numberOfTransactionTodayForCurrency = 5
        let numberOfTotalTransaction = 5
        let additionalFee = 0.0

        let input = FeeRule.Input(numberOfTransactionsForToday: numberOfTransactionTodayForCurrency,
                                  numberOfTotalTransactionForToday: numberOfTotalTransaction,
                                  additionalFee: additionalFee,
                                  amount: 100)
        
        let amount = FeeRule.allRules.map { $0.evaluate(input) }.reduce(0, +)
        XCTAssertEqual(amount, 0, accuracy: 0.01)
    }
    
    func testSmallFee() throws {
        let numberOfTransactionTodayForCurrency = 6
        let numberOfTotalTransaction = 6
        let additionalFee = 0.0
        
        let input = FeeRule.Input(numberOfTransactionsForToday: numberOfTransactionTodayForCurrency,
                                  numberOfTotalTransactionForToday: numberOfTotalTransaction,
                                  additionalFee: additionalFee,
                                  amount: 100)
        
        let amount = FeeRule.allRules.map { $0.evaluate(input) }.reduce(0, +)
        XCTAssertEqual(amount, 0.7, accuracy: 0.01)
    }

    func test16TransactionsPerDayFee() throws {
        let numberOfTransactionTodayForCurrency = 9
        let numberOfTotalTransaction = 16
        let additionalFee = 0.30
        
        let input = FeeRule.Input(numberOfTransactionsForToday: numberOfTransactionTodayForCurrency,
                                  numberOfTotalTransactionForToday: numberOfTotalTransaction,
                                  additionalFee: additionalFee,
                                  amount: 100)
        
        let amount = FeeRule.allRules.map { $0.evaluate(input) }.reduce(0, +)
        XCTAssertEqual(amount, 1.5, accuracy: 0.01)
    }
}
