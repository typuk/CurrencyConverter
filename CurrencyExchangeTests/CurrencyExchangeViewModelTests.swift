//
//  CurrencyExchangeViewModelTests.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 25/03/2022.
//

import XCTest
import Combine

@testable import CurrencyExchange

class CurrencyExchangeViewModelTests: XCTestCase {
    
    private var viewModel: CurrencyExchangeViewModel!
    
    private var wallet: WalletMock!
    private var exchangeRateAPIService: ExchangeRateAPIMock!
    private var exchangeRateService: ExchangeRateServiceMock!
    private var cancellables: Set<AnyCancellable>!

    @MainActor override func setUp() {
        super.setUp()
        wallet = WalletMock()
        exchangeRateAPIService = ExchangeRateAPIMock()
        exchangeRateService = ExchangeRateServiceMock()
        viewModel = CurrencyExchangeViewModel(wallet: wallet, exchangeRateAPIService: exchangeRateAPIService, exchangeRateService: exchangeRateService)
        cancellables = []
    }
    
    @MainActor func testCurrencyBalances() throws {
        wallet.availableBalancesSubject.send([CurrencyBalance(currency: .euro, amount: 100), CurrencyBalance(currency: "USD", amount: 200)])
        exchangeRateAPIService.filename = "CurrencyExchangeModel"
        viewModel.startLoading()
        
        let currencyBalances = try awaitPublisher(viewModel.$currencyBalances.drop(while: \.isEmpty).first())
        XCTAssertEqual(currencyBalances.count, 168)
        XCTAssertEqual(currencyBalances[0].currency, "USD", "First currency should be with largest amount")
        XCTAssertEqual(currencyBalances[1].currency, .euro, "Currency with amounts should be on top of list")
        
        let duplicates = Dictionary(grouping: currencyBalances, by: \.currency)
            .filter { $1.count > 1 }
        
        XCTAssertEqual(duplicates.count, 0, "There should be no duplicates")
    }
    
    @MainActor func testSubmitButtonEnabled() throws {
        wallet.availableBalancesSubject.send([CurrencyBalance(currency: .euro, amount: 100), CurrencyBalance(currency: "USD", amount: 200)])
        exchangeRateAPIService.filename = "CurrencyExchangeModel"
        viewModel.startLoading()
        
        viewModel.$loadingState // Setting values after viewModel is ready
            .filter { if case .loaded = $0 { return true } else { return false } }
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [viewModel] _ in
                viewModel?.sellingCurrencyAmount = "80"
                viewModel?.sellingCurrencyAmount = "160"
                viewModel?.sellingCurrency = "USD"
            }
            .store(in: &cancellables)
        
        let isSubmitEnabled = try awaitPublisher(viewModel.$isSubmitEnabled.dropFirst(2).collect(3).first())
        XCTAssertEqual(isSubmitEnabled[0], true)
        XCTAssertEqual(isSubmitEnabled[1], false)
        XCTAssertEqual(isSubmitEnabled[2], true)
    }
    
    @MainActor func testSuccessiveCurrencyConversation() throws {
        wallet.availableBalancesSubject.send([CurrencyBalance(currency: .euro, amount: 100), CurrencyBalance(currency: "USD", amount: 200)])
        exchangeRateAPIService.filename = "CurrencyExchangeModel"
        viewModel.startLoading()
        
        viewModel.$loadingState // Setting values after viewModel is ready
            .filter { if case .loaded = $0 { return true } else { return false } }
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [viewModel] _ in
                viewModel?.sellingCurrencyAmount = "80"
                viewModel?.didTapSubmitButton()
            }
            .store(in: &cancellables)
    }
}
