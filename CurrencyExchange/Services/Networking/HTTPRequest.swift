//
//  HTTPRequest.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 23/03/2022.
//

import Foundation
import Combine

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}

protocol Request {
    var url: URL { get }
    var method: HTTPMethod { get }
}
