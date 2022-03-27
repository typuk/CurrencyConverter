//
//  ViewModelFactory.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 27/03/2022.
//

import Foundation

class ViewModelFactory {
    
    @MainActor func makeCurrencyExchangeViewModel() -> CurrencyExchangeViewModel {
        let storage = StorageService(keyValueStoring: UserDefaults.standard)
        let wallet = WalletService(storage: storage)
        let exchangeRateAPIService = CurrencyExchangeRateAPIService(dataLoader: HTTPDataLoader())
        let currencyConversionService = CurrencyExchangeRateServiceImplementation(storage: storage, wallet: wallet)
        let viewModel = CurrencyExchangeViewModel(wallet: wallet,
                                                  exchangeRateAPIService: exchangeRateAPIService,
                                                  currencyConversionService: currencyConversionService)
        
        return viewModel
    }
    
}
