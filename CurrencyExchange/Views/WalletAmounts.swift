//
//  WalletAmounts.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 21/03/2022.
//

import SwiftUI

struct WalletAmounts: View {
    
    @Binding var availableBalances: [CurrencyBalance]
    
    private let numberFormatter: NumberFormatter = {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = ""
        return currencyFormatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("My Balances")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(availableBalances, id: \.self) { balance in
                        Text(numberFormatter.string(from: balance.amount as NSNumber) ?? "") +
                        Text(" ") +
                        Text(balance.currency)
                    }
                }
            }
            .padding([.leading, .trailing], 16)
        }
    }
}

struct WalletAmounts_Previews: PreviewProvider {
    static var previews: some View {
        WalletAmounts(availableBalances: .constant([CurrencyBalance(currency: .euro, amount: 1.66)]))
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
