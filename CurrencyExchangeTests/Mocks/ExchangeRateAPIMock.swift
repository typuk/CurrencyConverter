//
//  ExchangeRateAPIMock.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 25/03/2022.
//

import Foundation
import Combine
@testable import CurrencyExchange

final class ExchangeRateAPIMock: BaseMockable, ExchangeRateAPI {
    
    func loadExchangeRates() -> AnyPublisher<CurrencyExchangeModel, Error> {
        returnMockable()
    }
    
}
