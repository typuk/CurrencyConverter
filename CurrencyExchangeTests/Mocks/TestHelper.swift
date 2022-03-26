//
//  TestHelper.swift
//  CurrencyExchangeTests
//
//  Created by Arthur Alehna on 25/03/2022.
//

import Foundation

final class TestHelper {
    
    struct TestHelperError: Error { }
    
    static func getDataContent(from file: String) throws -> Data {
        
        guard let fileURL = Bundle(identifier: "com.arturs.alehna.CurrencyExchangeTests")?
            .url(forResource: file, withExtension: "json") else {
            throw TestHelperError()
        }
        
        let jsonData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
        return jsonData
    }
}
