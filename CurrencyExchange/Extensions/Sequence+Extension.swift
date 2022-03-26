//
//  Sequence+Extension.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 24/03/2022.
//

import Foundation

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { leftSide, rightSide in
            leftSide[keyPath: keyPath] < rightSide[keyPath: keyPath]
        }
    }
}
