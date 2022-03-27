//
//  ExchangeRateServiceTests.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 23/03/2022.
//

import XCTest

@testable import CurrencyExchange

class ExchangeRateServiceTests: XCTestCase {

    private var exchangeService: CurrencyConversionService!
    private var storage: StorageMock!
    private var wallet: WalletMock!
    
    override func setUp() {
        super.setUp()
        
        wallet = WalletMock()
        storage = StorageMock()
        exchangeService = CurrencyExchangeRateServiceImplementation(storage: storage, wallet: wallet)
    }
    
    func testEuroAmountConversion() throws {
        let currencyModel = CurrencyExchangeModel(base: .euro, date: "", rates: [CurrencyExchangeRate(currency: "USD", exchangeRate: 1.12)])
        exchangeService.updateExchnageRates(with: currencyModel)
        let transaction = CurrencyExchangeTransaction(amount: 100, fromCurrency: "EUR", toCurrency: "USD")
        let amount = try exchangeService.calculateTransactionAmount(for: transaction)
        XCTAssertEqual(amount, 112.0, accuracy: 0.01)
    }

    func testNotEuroAmountConversion() throws {
        let currencyModel = CurrencyExchangeModel(base: .euro, date: "", rates: [CurrencyExchangeRate(currency: "USD", exchangeRate: 1.09),
                                                                                 CurrencyExchangeRate(currency: "GBP", exchangeRate: 0.83)])
        exchangeService.updateExchnageRates(with: currencyModel)
        let transaction = CurrencyExchangeTransaction(amount: 100, fromCurrency: "USD", toCurrency: "GBP")
        let amount = try exchangeService.calculateTransactionAmount(for: transaction)
        XCTAssertEqual(amount, 76.14, accuracy: 0.01)
    }
    
    func testUSDToEURConversionWithNoFee() throws {
        wallet.availableBalancesMockData = [CurrencyBalance(currency: .euro, amount: 1000)]
        let currencyModel = CurrencyExchangeModel(base: .euro, date: "", rates: [CurrencyExchangeRate(currency: "USD", exchangeRate: 1.12)])
        exchangeService.updateExchnageRates(with: currencyModel)
        
        let transaction = CurrencyExchangeTransaction(amount: 100, fromCurrency: .euro, toCurrency: "USD")
        let result = try exchangeService.convertCurrency(for: transaction)
        
        XCTAssertEqual(wallet.withdraws[1].first?.key, .euro)
        XCTAssertEqual(wallet.withdraws[1].first?.value ?? 0, 0, accuracy: 0.01)
        XCTAssertEqual(result.conversionFee, 0)
        
        XCTAssertEqual(result.convertedAmount, 112.0, accuracy: 0.01)
        XCTAssertEqual(wallet.deposits.first?.first?.value ?? 0, 112.0, accuracy: 0.01)
        
        XCTAssertEqual(wallet.deposits.count, 1)
        XCTAssertEqual(wallet.withdraws.count, 2)
        XCTAssertEqual(wallet.deposits.first?.first?.key, "USD")
        
        XCTAssertEqual(wallet.withdraws[0].first?.key, .euro)
        XCTAssertEqual(wallet.withdraws[0].first?.value ?? 0, 100, accuracy: 0.01)
    }
    
    func testUSDToEURConversionWithSmallFee() throws {
        storage.transactionListMockData = TransactionList(transactions: ["EUR": 6])
        wallet.availableBalancesMockData = [CurrencyBalance(currency: .euro, amount: 1000)]
        let currencyModel = CurrencyExchangeModel(base: .euro, date: "", rates: [CurrencyExchangeRate(currency: "USD", exchangeRate: 1.12)])
        exchangeService.updateExchnageRates(with: currencyModel)
        
        let transaction = CurrencyExchangeTransaction(amount: 100, fromCurrency: .euro, toCurrency: "USD")
        let result = try exchangeService.convertCurrency(for: transaction)
        
        XCTAssertEqual(wallet.withdraws[1].first?.key, .euro)
        XCTAssertEqual(wallet.withdraws[1].first?.value ?? 0, 0.7, accuracy: 0.01)
        XCTAssertEqual(result.conversionFee, 0.7, accuracy: 0.01)
        
        XCTAssertEqual(result.convertedAmount, 112.0, accuracy: 0.01)
        XCTAssertEqual(wallet.deposits.first?.first?.value ?? 0, 112.0, accuracy: 0.01)
        
        XCTAssertEqual(wallet.deposits.count, 1)
        XCTAssertEqual(wallet.withdraws.count, 2)
        XCTAssertEqual(wallet.deposits.first?.first?.key, "USD")
        
        XCTAssertEqual(wallet.withdraws[0].first?.key, .euro)
        XCTAssertEqual(wallet.withdraws[0].first?.value ?? 0, 100, accuracy: 0.01)
    }
    
    func testUSDToEURConversionWithLargeFee() throws {
        storage.transactionListMockData = TransactionList(transactions: ["EUR": 6, "GBP": 9, "USD": 5])
        wallet.availableBalancesMockData = [CurrencyBalance(currency: .euro, amount: 1000)]
        let currencyModel = CurrencyExchangeModel(base: .euro, date: "", rates: [CurrencyExchangeRate(currency: "USD", exchangeRate: 1.12)])
        exchangeService.updateExchnageRates(with: currencyModel)
        
        let transaction = CurrencyExchangeTransaction(amount: 100, fromCurrency: .euro, toCurrency: "USD")
        let result = try exchangeService.convertCurrency(for: transaction)
        
        XCTAssertEqual(wallet.withdraws[1].first?.key, .euro)
        XCTAssertEqual(wallet.withdraws[1].first?.value ?? 0, 1.5, accuracy: 0.01)
        XCTAssertEqual(result.conversionFee, 1.5, accuracy: 0.01)
        
        XCTAssertEqual(result.convertedAmount, 112.0, accuracy: 0.01)
        XCTAssertEqual(wallet.deposits.first?.first?.value ?? 0, 112.0, accuracy: 0.01)
        
        XCTAssertEqual(wallet.deposits.count, 1)
        XCTAssertEqual(wallet.withdraws.count, 2)
        XCTAssertEqual(wallet.deposits.first?.first?.key, "USD")
        
        XCTAssertEqual(wallet.withdraws[0].first?.key, .euro)
        XCTAssertEqual(wallet.withdraws[0].first?.value ?? 0, 100, accuracy: 0.01)
    }
    
    func testTransactionSaving() throws {
        
        wallet.availableBalancesMockData = [CurrencyBalance(currency: .euro, amount: 1000)]
        let currencyModel = CurrencyExchangeModel(base: .euro, date: "", rates: [CurrencyExchangeRate(currency: "USD", exchangeRate: 1.12)])
        exchangeService.updateExchnageRates(with: currencyModel)
        
        let transaction = CurrencyExchangeTransaction(amount: 100, fromCurrency: .euro, toCurrency: "USD")
        _ = try exchangeService.convertCurrency(for: transaction)
        XCTAssertEqual(storage.transactionListMockData?.totalTransactionCount, 1)
        XCTAssertEqual(storage.transactionListMockData?.transactions.count, 1)
        XCTAssertEqual(storage.transactionListMockData?.transactions[.euro], 1)
        _ = try exchangeService.convertCurrency(for: transaction)
        XCTAssertEqual(storage.transactionListMockData?.totalTransactionCount, 2)
        XCTAssertEqual(storage.transactionListMockData?.transactions.count, 1)
        XCTAssertEqual(storage.transactionListMockData?.transactions[.euro], 2)
    }
    
    func testExchangeRateUpdate() throws {
        
        wallet.availableBalancesMockData = [CurrencyBalance(currency: .euro, amount: 1000)]
        let currencyModel1 = CurrencyExchangeModel(base: .euro, date: "", rates: [CurrencyExchangeRate(currency: "USD", exchangeRate: 1.12)])
        let currencyModel2 = CurrencyExchangeModel(base: .euro, date: "", rates: [CurrencyExchangeRate(currency: "USD", exchangeRate: 1.20)])
        let transaction = CurrencyExchangeTransaction(amount: 100, fromCurrency: .euro, toCurrency: "USD")
        
        exchangeService.updateExchnageRates(with: currencyModel1)
        var result = try exchangeService.convertCurrency(for: transaction)
        XCTAssertEqual(result.convertedAmount, 112.0, accuracy: 0.01)
        
        exchangeService.updateExchnageRates(with: currencyModel2)
        result = try exchangeService.convertCurrency(for: transaction)
        XCTAssertEqual(result.convertedAmount, 120.0, accuracy: 0.01)
    }
}
