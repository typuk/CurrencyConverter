//
//  BaseMockable.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 25/03/2022.
//

import Foundation
import Combine

class BaseMockable {
    var filename: String?
    var returnValue: Any?
    var returnError: Error?
    
    func returnMockable<T: Decodable>() -> AnyPublisher<T, Error> {
        if let file = filename, let data = try? TestHelper.getDataContent(from: file) {
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                return Just(response)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } catch {
                return Fail(outputType: T.self, failure: error)
                    .eraseToAnyPublisher()
            }
        } else if let returnValue = returnValue as? T {
            return Just(returnValue)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else if let error = returnError {
            return Fail(outputType: T.self, failure: error)
                .eraseToAnyPublisher()
        }
        
        return Empty(completeImmediately: true, outputType: T.self, failureType: Error.self)
            .eraseToAnyPublisher()
    }
}
