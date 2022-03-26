//
//  LoadingState.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 26/03/2022.
//

import Foundation

enum LoadingState: Equatable {
    case isPreparing
    case isLoading(Bool)
    case loaded
    case failed(Error)
    
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.isPreparing, .isPreparing):
            return true
        case let (.isLoading(lhs), .isLoading(rhs)):
            return lhs == rhs
        case (.loaded, .loaded):
            return true
        default:
            return false
        }
    }
}
