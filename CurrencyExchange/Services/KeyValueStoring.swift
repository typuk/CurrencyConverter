//
//  KeyValueStoring.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 22/03/2022.
//

import Foundation

public protocol KeyValueStoring: AnyObject {
    func get<T>(_ key: String) throws -> T?
    func set<T>(_ value: T, key: String) throws
    func remove(_ key: String) throws
    
    subscript<T>(key: String) -> T? { get set }
}

extension KeyValueStoring {
    
    public subscript<T>(key: String) -> T? {
        get {
            return try? get(key)
        }
        set {
            if let value = newValue {
                try? set(value, key: key)
            } else {
                try? remove(key)
            }
        }
    }
}

extension UserDefaults: KeyValueStoring {
    public func get<T>(_ key: String) throws -> T? {
        value(forKey: key) as? T
    }
    
    public func set<T>(_ value: T, key: String) throws {
        set(value, forKey: key)
    }
    
    public func remove(_ key: String) throws {
        removeObject(forKey: key)
    }
}
