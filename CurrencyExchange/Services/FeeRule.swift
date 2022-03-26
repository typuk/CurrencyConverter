//
//  FeeRule.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 22/03/2022.
//

import Foundation

struct FeeRule {
    var evaluate: (Input) -> Double
}

extension FeeRule {
    struct Input {
        let numberOfTransactionsForToday: Int
        let numberOfTotalTransactionForToday: Int
        let additionalFee: Double
        let amount: Double
    }
}

extension FeeRule {
    
    static var allRules: [FeeRule] {
        [.simpleFee, .extendedRule]
    }
    
    static var simpleFee: FeeRule {
        FeeRule { input in
            guard input.numberOfTransactionsForToday >= 5, input.numberOfTotalTransactionForToday < 15 else {
                return 0
            }
            
            return 0.007 * input.amount
        }
    }
    
    static var extendedRule: FeeRule {
        FeeRule { input in
            guard input.numberOfTotalTransactionForToday >= 15 else {
                return 0
            }
            
            return (0.012 * input.amount) + input.additionalFee
        }
    }
}
