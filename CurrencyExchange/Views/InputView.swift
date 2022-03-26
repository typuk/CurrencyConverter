//
//  InputView.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 21/03/2022.
//

import SwiftUI

enum InputViewType {
    case sell
    case buy
}

struct InputView: View {
    
    var type: InputViewType
    
    @Binding var selectedCurrency: String
    @Binding var inputFieldAmount: String
    @Binding var possibleCurrencies: [CurrencyBalance]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ImageWithCircle(circleColor: type.circleColor, imageSystemName: type.iconImageName)
                    .padding(.leading, 16)
                    .padding(.trailing, 2)
                Text(type.titleText)
                Spacer()
                if type == .buy {
                    Text(inputFieldAmount)
                        .foregroundColor(.green)
                        .frame(width: 80, alignment: .leading)
                } else {
                    TextField("Amount", text: $inputFieldAmount)
                        .keyboardType(.decimalPad)
                        .frame(width: 80, alignment: .leading)
                }
                Picker("", selection: $selectedCurrency) {
                    ForEach(possibleCurrencies, id: \.self) { currency in
                        Text(currency.currency).tag(currency.currency)
                    }
                }
                .padding()
            }
            Rectangle()
                .foregroundColor(Color(UIColor.systemGray5))
                .padding(.leading, 58)
                .frame(height: 0.5, alignment: .trailing)
        }
    }
}

private extension InputViewType {
    var titleText: String {
        switch self {
        case .sell:
            return "Sell"
        case .buy:
            return "Receive"
        }
    }
    
    var iconImageName: String {
        switch self {
        case .sell:
            return "arrow.up"
        case .buy:
            return "arrow.down"
        }
    }
    
    var circleColor: Color {
        switch self {
        case .sell:
            return .red
        case .buy:
            return .green
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InputView(type: .sell,
                      selectedCurrency: .constant(.euro),
                      inputFieldAmount: .constant("1000"),
                      possibleCurrencies: .constant([CurrencyBalance(currency: .euro, amount: 0)]))
            .previewLayout(PreviewLayout.sizeThatFits)
            InputView(type: .buy,
                      selectedCurrency: .constant("USD"),
                      inputFieldAmount: .constant("+ 1000"),
                      possibleCurrencies: .constant([CurrencyBalance(currency: "USD", amount: 0)]))
            .previewLayout(PreviewLayout.sizeThatFits)
        }
    }
}
