//
//  CurrencyExchangeViewModel.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 21/03/2022.
//

import Foundation
import Combine

@MainActor class CurrencyExchangeViewModel: ObservableObject {
    
    private var cancellableBag = Set<AnyCancellable>()
    private var networkingBag = Set<AnyCancellable>()
    
    private let wallet: Wallet
    private let exchangeRateAPIService: CurrencyExchangeRateAPI
    private let exchangeRateService: CurrencyExchangeRateService
    
    private let currencyExchangeModel = PassthroughSubject<CurrencyExchangeModel, Never>()
    private let didTapSubmitButtonSubject = PassthroughSubject<Void, Never>()
    
    private let numberFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = ""
        return currencyFormatter
    }()
    
    private var transaction: AnyPublisher<CurrencyExchangeTransaction, Never> {
        Publishers.CombineLatest3($sellingCurrencyAmount.map { Double($0) ?? 0 }, $sellingCurrency, $buyingCurrency)
            .map { amount, fromCurrency, toCurrency -> CurrencyExchangeTransaction in
                CurrencyExchangeTransaction(amount: amount, fromCurrency: fromCurrency, toCurrency: toCurrency)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private let needsUpdate: AnyPublisher<Void, Never>
    
    @Published var sellingCurrency: Currency = .euro
    @Published var buyingCurrency: Currency = "USD"
    @Published var sellingCurrencyAmount = ""
    @Published var buyingCurrencyAmount = ""
    
    @Published var currencyBalances: [CurrencyBalance] = []
    @Published var isSubmitEnabled = false
    @Published var shouldShowAlert = false
    @Published var loadingState: LoadingState = .isPreparing
    
    var alertMessage: AlertMessage? = nil { didSet { shouldShowAlert = alertMessage != nil } }
    
    init(wallet: Wallet,
         exchangeRateAPIService: CurrencyExchangeRateAPI,
         exchangeRateService: CurrencyExchangeRateService,
         needsUpdate: AnyPublisher<Void, Never>? = nil) {
        self.wallet = wallet
        self.exchangeRateAPIService = exchangeRateAPIService
        self.exchangeRateService = exchangeRateService
        
        let timer = Timer.publish(every: 15, on: .main, in: .default)
            .autoconnect()
            .map { _ in () }
            .eraseToAnyPublisher()
        
        self.needsUpdate = needsUpdate ?? timer

        setupBindings()
    }
    
    func startLoading() {
        networkingBag.removeAll()
        loadingState = .isPreparing
        
        Publishers.Merge(Just(false), needsUpdate.map { _ in true })
            .handleEvents(receiveOutput: { [weak self] initialLoading in
                self?.loadingState = .isLoading(initialLoading)
            })
            .flatMap { [exchangeRateAPIService] _ in
                exchangeRateAPIService.loadExchangeRates()
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] in
                if case .failure(let error) = $0 {
                    self?.loadingState = .failed(error)
                }
            }, receiveValue: { [weak self] value in
                self?.currencyExchangeModel.send(value)
                
                if self?.loadingState != .loaded {
                    self?.loadingState = .loaded
                }
            })
            .store(in: &networkingBag)
    }
    
    func didTapSubmitButton() {
        didTapSubmitButtonSubject.send(())
    }
}

private extension CurrencyExchangeViewModel {
    
    func setupBindings() {
        Publishers
            .CombineLatest($currencyBalances, transaction)
            .map { [weak self] currencies, transaction -> Bool in
                guard let self = self else { return false }
                let haveCurrencies = !currencies.isEmpty
                do {
                    let fee = try self.exchangeRateService.calculateTransactionFee(for: transaction)
                    let currencyBalance = currencies.first(where: { $0.currency == transaction.fromCurrency })?.amount ?? 0
                    return haveCurrencies && (currencyBalance >= fee + transaction.amount) && transaction.amount > 0
                } catch {
                    return false
                }
            }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: &$isSubmitEnabled)
        
        transaction
            .map { [weak self] transaction in
                (try? self?.exchangeRateService.calculateTransactionAmount(for: transaction)) ?? 0
            }
            .compactMap { [weak self] in self?.numberFormatter.string(from: $0 as NSNumber) }
            .map { "+ \($0)" }
            .receive(on: RunLoop.main)
            .assign(to: &$buyingCurrencyAmount)
        
        didTapSubmitButtonSubject.withLatestFrom(transaction) { _, transaction in transaction }
            .sink(receiveValue: { [weak self] transaction in
                self?.convertCurrencies(for: transaction)
            })
            .store(in: &cancellableBag)
        
        currencyExchangeModel
            .sink(receiveValue: { [weak self] model in
                self?.exchangeRateService.updateExchnageRates(with: model)
            })
            .store(in: &cancellableBag)
        
        Publishers
            .CombineLatest(currencyExchangeModel, wallet.availableBalances)
            .map { exchangeRates, availableBalances -> [CurrencyBalance] in
                let balances = availableBalances.sorted(by: \.amount).reversed()
                let exchangeRates = exchangeRates.rates
                    .filter { !availableBalances.map { $0.currency }.contains($0.currency) }
                    .map { CurrencyBalance(currency: $0.currency, amount: 0) }
                    .sorted(by: \.currency)
                
                return balances + exchangeRates
            }
            .receive(on: RunLoop.main)
            .assign(to: &$currencyBalances)
    }

    func convertCurrencies(for transaction: CurrencyExchangeTransaction) {
        do {
            let transactionResult = try exchangeRateService.convertCurrency(for: transaction)
            alertMessage = alertMessage(for: transactionResult)
        } catch {
            alertMessage = alertMessage(for: error)
        }
    }
    
    func alertMessage(for transactionResult: CurrencyExchangeResult) -> AlertMessage {
        let sellingAmount = numberFormatter.string(from: transactionResult.amount as NSNumber) ?? ""
        let buyingAmount = numberFormatter.string(from: transactionResult.convertedAmount as NSNumber) ?? ""
        let conversionFeeAmount = numberFormatter.string(from: transactionResult.conversionFee as NSNumber) ?? ""
        
        let message = "You have converted \(sellingAmount) \(transactionResult.fromCurrency)"
        + " to \(buyingAmount) \(transactionResult.toCurrency). "
        + "Commission Fee - \(conversionFeeAmount)."
        
        return AlertMessage(title: "Conversion Successful", message: message)
    }
    
    func alertMessage(for error: Error) -> AlertMessage {
        return AlertMessage(title: "Error", message: error.localizedDescription)
    }
}
