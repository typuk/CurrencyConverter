//
//  ContentView.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 25/03/2022.
//

import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        Group {
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                Text("Running unit tests")
            } else {
                let storage = StorageService(keyValueStoring: UserDefaults.standard)
                let wallet = WalletService(storage: storage)
                let viewModel = CurrencyExchangeViewModel(wallet: wallet,
                                                          exchangeRateAPIService: CurrencyExchangeRateAPIService(dataLoader: HTTPDataLoader()),
                                                          exchangeRateService: CurrencyExchangeRateServiceImplementation(storage: storage, wallet: wallet))
                ExchangeView()
                    .environmentObject(viewModel)
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
