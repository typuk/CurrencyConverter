//
//  WalletTests.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 25/03/2022.
//

import XCTest
import Combine

@testable import CurrencyExchange

class WalletTests: XCTestCase {
    
    private var storage: StorageMock!
    private var wallet: Wallet!

    override func setUp() {
        super.setUp()
        
        storage = StorageMock()
        wallet = WalletService(storage: storage)
    }

    func testInitialValues() throws {
        let balances = try awaitPublisher(wallet.availableBalances.first())
        XCTAssertEqual(balances.count, 1)
        XCTAssertEqual(balances.first?.currency, Constants.balanceInitialCurrency)
        XCTAssertEqual(balances.first?.amount, Constants.balanceInitialAmount)
    }
    
    func testPreSavedValues() throws {
        storage.currencyBalanceMockData = [CurrencyBalance(currency: .euro, amount: 5000), CurrencyBalance(currency: "USD", amount: 300)]
        wallet = WalletService(storage: storage)

        let balances = try awaitPublisher(wallet.availableBalances.first())
        
        XCTAssertEqual(balances.count, 2)
        XCTAssertEqual(balances.first(where: { $0.currency == .euro })?.amount, 5000)
        XCTAssertEqual(balances.first(where: { $0.currency == "USD" })?.amount, 300)
        XCTAssertEqual(try wallet.balance(for: .euro), 5000)
        XCTAssertEqual(try wallet.balance(for: "USD"), 300)
    }
    
    func testDepositForExistingCurrency() throws {
        try wallet.makeDeposit(currency: .euro, amount: 100)

        let balances = try awaitPublisher(wallet.availableBalances.first())
        
        XCTAssertEqual(balances.count, 1)
        XCTAssertEqual(balances.first?.currency, .euro)
        XCTAssertEqual(balances.first?.amount, 1100)
        XCTAssertEqual(try wallet.balance(for: .euro), 1100)
        XCTAssertEqual(storage.currencyBalanceMockData?.count, 1)
        XCTAssertEqual(storage.currencyBalanceMockData?.first?.currency, .euro)
        XCTAssertEqual(storage.currencyBalanceMockData?.first?.amount, 1100)
    }
    
    func testDepositForNonExistingCurrency() throws {
        try wallet.makeDeposit(currency: "GBP", amount: 456)
        
        let balances = try awaitPublisher(wallet.availableBalances.first())
        
        XCTAssertEqual(balances.count, 2)
        XCTAssertEqual(try wallet.balance(for: "GBP"), 456)
        XCTAssertEqual(try wallet.balance(for: .euro), 1000)
        XCTAssertEqual(balances.first(where: { $0.currency == "GBP" })?.amount, 456)
        XCTAssertEqual(storage.currencyBalanceMockData?.count, 2)
        XCTAssertEqual(storage.currencyBalanceMockData?.first(where: { $0.currency == "GBP" })?.amount, 456)
    }
    
    func testWithdrawForExistingCurrency() throws {
        try wallet.makeWithdraw(currency: .euro, amount: 100)
        
        let balances = try awaitPublisher(wallet.availableBalances.first())
        
        XCTAssertEqual(balances.count, 1)
        XCTAssertEqual(balances.first?.currency, .euro)
        XCTAssertEqual(balances.first?.amount, 900)
        XCTAssertEqual(storage.currencyBalanceMockData?.count, 1)
        XCTAssertEqual(storage.currencyBalanceMockData?.first?.currency, .euro)
        XCTAssertEqual(storage.currencyBalanceMockData?.first?.amount, 900)
    }
}
