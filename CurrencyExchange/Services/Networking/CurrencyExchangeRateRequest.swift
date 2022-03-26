//
//  CurrencyExchangeRateRequest.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 23/03/2022.
//

import Foundation

struct CurrencyExchangeRateRequest: Request {
    let url: URL
    let method: HTTPMethod = .get
    
    init(accessKey: String = Constants.accessKey) {
        url = URL(string: "http://api.exchangeratesapi.io/v1/latest?access_key=\(accessKey)")!
    }
}
