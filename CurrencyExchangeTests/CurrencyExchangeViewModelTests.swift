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
    private var exchangeRateAPIService: CurrencyExchangeRateAPIMock!
    private var exchangeRateService: CurrencyExchangeRateServiceMock!
    private var cancellables: Set<AnyCancellable>!

    @MainActor override func setUp() {
        super.setUp()
        wallet = WalletMock()
        exchangeRateAPIService = CurrencyExchangeRateAPIMock()
        exchangeRateService = CurrencyExchangeRateServiceMock()
        viewModel = CurrencyExchangeViewModel(wallet: wallet, exchangeRateAPIService: exchangeRateAPIService, currencyConversionService: exchangeRateService)
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
            .filter { .loaded == $0 }
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
    
    @MainActor func testSuccessiveCurrencyConversion() throws {
        wallet.availableBalancesSubject.send([CurrencyBalance(currency: .euro, amount: 100), CurrencyBalance(currency: "USD", amount: 200)])
        exchangeRateAPIService.filename = "CurrencyExchangeModel"
        viewModel.startLoading()
        
        viewModel.$loadingState // Setting values after viewModel is ready
            .filter { .loaded == $0 }
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [viewModel] _ in
                viewModel?.sellingCurrency = "EUR"
                viewModel?.buyingCurrency = "USD"
                viewModel?.sellingCurrencyAmount = "80"
                viewModel?.didTapSubmitButton()
            }
            .store(in: &cancellables)
        
        let shouldShowAlert = try awaitPublisher(viewModel.$shouldShowAlert.collect(2).first())
        
        XCTAssertEqual(shouldShowAlert[0], false)
        XCTAssertEqual(shouldShowAlert[1], true)
        XCTAssertEqual(viewModel.alertMessage?.title, "Conversion Successful")
    }
    
    @MainActor func testLoadingState() throws {

        let subject = PassthroughSubject<Void, Never>()
        let expectation = expectation(description: "CurrencyExchangeViewModelTests")
        
        viewModel = CurrencyExchangeViewModel(wallet: wallet,
                                              exchangeRateAPIService: exchangeRateAPIService,
                                              currencyConversionService: exchangeRateService,
                                              needsUpdate: subject.eraseToAnyPublisher())
        
        wallet.availableBalancesSubject.send([CurrencyBalance(currency: .euro, amount: 100), CurrencyBalance(currency: "USD", amount: 200)])
        exchangeRateAPIService.filename = "CurrencyExchangeModel"
        
        var loadingStateEvents: [LoadingState] = []
        viewModel.$loadingState.prefix(6)
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: {
                loadingStateEvents.append($0)
            })
            .store(in: &cancellables)

        viewModel.startLoading()
        
        subject.send(())
        subject.send(())
        subject.send(())
        
        waitForExpectations(timeout: 2)
        
        XCTAssertEqual(loadingStateEvents[0], .isPreparing)
        XCTAssertEqual(loadingStateEvents[1], .isPreparing)
        XCTAssertEqual(loadingStateEvents[2], .isLoading(false), "First loading should be self initiated")
        XCTAssertEqual(loadingStateEvents[3], .isLoading(true), "Loading should be timer initiated")
        XCTAssertEqual(loadingStateEvents[4], .isLoading(true), "Loading should be timer initiated")
        XCTAssertEqual(loadingStateEvents[5], .isLoading(true), "Loading should be timer initiated")
    }
}
