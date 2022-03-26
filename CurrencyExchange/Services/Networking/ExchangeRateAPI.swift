//
//  ExchangeRateAPI.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 22/03/2022.
//

import Foundation
import Combine

protocol ExchangeRateAPI {
    func loadExchangeRates() -> AnyPublisher<CurrencyExchangeModel, Error>
}

class ExchangeRateAPIService: ExchangeRateAPI {
    
    private let decoder = JSONDecoder()
    private let dataLoader: DataLoader
     
    init(dataLoader: DataLoader) {
        self.dataLoader = dataLoader
    }
    
    func loadExchangeRates() -> AnyPublisher<CurrencyExchangeModel, Error> {
        let request = CurrencyExchangeRateRequest()
        return dataLoader.load(request: request)
            .decode(type: CurrencyExchangeModel.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
