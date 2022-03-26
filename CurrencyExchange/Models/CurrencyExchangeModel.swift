//
//  CurrencyExchangeModel.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 23/03/2022.
//

import Foundation

struct CurrencyExchangeRate: Decodable, Hashable {
    var currency: String
    var exchangeRate: Double
}

struct CurrencyExchangeModel: Decodable {
    let base: String
    let date: String
    let rates: [CurrencyExchangeRate]
    
    enum CodingKeys: String, CodingKey {
        case base
        case date
        case rates
    }
    
    init(base: String, date: String, rates: [CurrencyExchangeRate]) {
        self.base = base
        self.date = date
        self.rates = rates
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        base = try values.decode(String.self, forKey: .base)
        date = try values.decode(String.self, forKey: .date)
        
        let rates = try values.decode([String: Double].self, forKey: .rates)
        self.rates = rates.map { CurrencyExchangeRate(currency: $0.key, exchangeRate: $0.value) }
    }
}
