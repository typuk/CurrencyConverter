//
//  ExchangeView.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 19/03/2022.
//

import SwiftUI
import Combine

struct ExchangeView: View {
    
    @EnvironmentObject var viewModel: CurrencyExchangeViewModel

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Currency Exchange")
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .onAppear {
            viewModel.startLoading()
        }
    }
    
    private var content: AnyView {
        switch viewModel.loadingState {
        case .isPreparing:
            return AnyView(loadingView())
        case .loaded:
            return AnyView(loadedView())
        case .failed(let error):
            return AnyView(failedView(error))
        case .isLoading(let dataCached):
            if dataCached {
                return AnyView(loadedView())
            } else {
                return AnyView(loadingView())
            }
        }
    }
}

private extension ExchangeView {

    func loadingView() -> some View {
        AnyView(ProgressView("Loading")
            .font(.title)
            .progressViewStyle(.circular))
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            viewModel.startLoading()
        })
    }

    func loadedView() -> some View {
            VStack(alignment: .leading) {
                WalletAmounts(availableBalances: $viewModel.currencyBalances)
                Text("Currency Exchange")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                InputView(type: .sell,
                          selectedCurrency: $viewModel.sellingCurrency,
                          inputFieldAmount: $viewModel.sellingCurrencyAmount,
                          possibleCurrencies: $viewModel.currencyBalances)
                InputView(type: .buy,
                          selectedCurrency: $viewModel.buyingCurrency,
                          inputFieldAmount: $viewModel.buyingCurrencyAmount,
                          possibleCurrencies: $viewModel.currencyBalances)
                Spacer()
                Button(action: {
                    viewModel.didTapSubmitButton()
                }, label: {
                    Text("Submit")
                        .frame(minWidth: 0, maxWidth: .infinity)
                })
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isSubmitEnabled)
                .padding()
            }
            .alert(isPresented: $viewModel.shouldShowAlert) {
                Alert(title: Text(viewModel.alertMessage?.title ?? ""),
                      message: Text(viewModel.alertMessage?.message ?? ""),
                      dismissButton: .default(Text("OK")))
            }
    }
}

struct ExchangeView_Previews: PreviewProvider {
    static var previews: some View {
        ExchangeView()
    }
}
