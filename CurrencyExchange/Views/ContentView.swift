//
//  ContentView.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 25/03/2022.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    private let viewModelFactory = ViewModelFactory()
    
    var body: some View {
        Group {
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                Text("Running unit tests")
            } else {
                let viewModel = viewModelFactory.makeCurrencyExchangeViewModel()
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
