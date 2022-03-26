//
//  Date+Extension.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 22/03/2022.
//

import Foundation

extension Date {
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }
}
