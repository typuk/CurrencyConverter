//
//  Publisher+Extension.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 24/03/2022.
//

import Foundation
import Combine

extension Publisher {
    func withLatestFrom<Other: Publisher, Result>(_ other: Other,
                                                  resultSelector: @escaping (Output, Other.Output) -> Result)
    -> AnyPublisher<Result, Failure> where Other.Failure == Failure {
        let upstream = share()
        
        return other
            .map { second in upstream.map { resultSelector($0, second) } }
            .switchToLatest()
            .zip(upstream)
            .map(\.0)
            .eraseToAnyPublisher()
    }
}
