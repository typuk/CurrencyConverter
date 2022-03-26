//
//  DataLoaderMock.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 25/03/2022.
//

import Foundation
import Combine
@testable import CurrencyExchange

final class DataLoaderMock: BaseMockable, DataLoader {

    func load(request: Request) -> AnyPublisher<Data, Error> {
        returnMockable()
    }
}
