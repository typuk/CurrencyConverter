//
//  ExchangeRateAPITests.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 25/03/2022.
//

import XCTest
import Combine

@testable import CurrencyExchange

class ExchangeRateAPITests: XCTestCase {
    
    private var dataLoader: DataLoaderMock!
    private var exchangeRateAPI: CurrencyExchangeRateAPI!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        
        dataLoader = DataLoaderMock()
        exchangeRateAPI = CurrencyExchangeRateAPIService(dataLoader: dataLoader)
        cancellables = []
    }
    
    func testDataParsing() throws {
        let data = try TestHelper.getDataContent(from: "CurrencyExchangeModel")
        let response = try JSONDecoder().decode(CurrencyExchangeModel.self, from: data)
        XCTAssertEqual(response.rates.count, 168)
        XCTAssertEqual(response.date, "2022-03-23")
        XCTAssertNotNil(response.base, .euro)
    }
    
    func testValidData() throws {
        let data = try TestHelper.getDataContent(from: "CurrencyExchangeModel")
        dataLoader.returnValue = data
        let expectation = expectation(description: "ExchangeRateAPI")
        var model: CurrencyExchangeModel?
        var error: Error?
        
        exchangeRateAPI.loadExchangeRates()
            .sink(receiveCompletion: {
                if case .failure(let encounteredError) = $0 {
                    error = encounteredError
                }
                expectation.fulfill()
            }, receiveValue: {
                model = $0
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1)
        XCTAssertNil(error)
        XCTAssertEqual(model?.rates.count, 168)
        XCTAssertEqual(model?.date, "2022-03-23")
        XCTAssertNotNil(model?.base, .euro)
    }
    
    func testInvalidData() throws {
        dataLoader.returnValue = invalidCurrencyExchangeModel
        let expectation = expectation(description: "ExchangeRateAPI")
        var model: CurrencyExchangeModel?
        var error: Error?
        
        exchangeRateAPI.loadExchangeRates()
            .sink(receiveCompletion: {
                if case .failure(let encounteredError) = $0 {
                    error = encounteredError
                }
                expectation.fulfill()
            }, receiveValue: {
                model = $0
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1)
        XCTAssertNil(model)
        XCTAssertNotNil(error)
    }
    
    private var invalidCurrencyExchangeModel: Data {
        let model = """
        {
          "base": null,
          "date": "2022-03-23",
          "exchangeRates": {
              "AED": 4.040893,
              "AFN": 96.260814,
              "ALL": 122.172489
          }
        }
        """
        
        return model.data(using: .utf8)!
    }
}
