//
//  DataLoader.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 23/03/2022.
//

import Foundation
import Combine

protocol DataLoader {
    func load(request: Request) -> AnyPublisher<Data, Error>
}

class HTTPDataLoader: DataLoader {
    
    private let urlSession = URLSession.shared
    
    func load(request: Request) -> AnyPublisher<Data, Error> {
        let urlRequest = makeUrlRequest(request: request)
        let publisher = urlSession
            .dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .mapError { error in
                error as Error
            }
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    private func makeUrlRequest(request: Request) -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        return urlRequest
    }
}
