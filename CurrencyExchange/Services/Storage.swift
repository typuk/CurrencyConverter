//
//  Storage.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 23/03/2022.
//

import Foundation

protocol Storage {
    func saveTransactionList(_ transactionList: TransactionList, date: String)
    func transactionList(for date: String) -> TransactionList?
    
    func saveCurrencyBalance(_ currencyBalance: [CurrencyBalance])
    func currencyBalance() -> [CurrencyBalance]?
}

// TODO: Replace UserDefaults with CoreData or Realm data bases
class StorageService: Storage {
    
    private enum StorageKeys: String {
        case currencyBalance
    }
    
    private let keyValueStoring: KeyValueStoring
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init(keyValueStoring: KeyValueStoring) {
        self.keyValueStoring = keyValueStoring
    }
    
    func saveTransactionList(_ transactionList: TransactionList, date: String) {
        if let data = try? encoder.encode(transactionList) {
            keyValueStoring[date] = data
        }
    }
    
    func transactionList(for date: String) -> TransactionList? {
        guard let data: Data = keyValueStoring[date],
                let transactionList = try? decoder.decode(TransactionList.self, from: data) else {
            return nil
        }
        
        return transactionList
    }
    
    func saveCurrencyBalance(_ currencyBalance: [CurrencyBalance]) {
        if let data = try? encoder.encode(currencyBalance) {
            keyValueStoring[StorageKeys.currencyBalance.rawValue] = data
        }
    }
    
    func currencyBalance() -> [CurrencyBalance]? {
        guard let data: Data = keyValueStoring[StorageKeys.currencyBalance.rawValue],
              let currencyBalance = try? decoder.decode([CurrencyBalance].self, from: data) else {
            return nil
        }
        
        return currencyBalance
    }
}
