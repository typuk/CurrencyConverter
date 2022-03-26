//
//  ImageWithCircle.swift
//  CurrencyExchange
//
//  Created by Arthur Alehna on 26/03/2022.
//

import SwiftUI

struct ImageWithCircle: View {
    @State private var width: CGFloat?
    
    let circleColor: Color
    let imageSystemName: String
    
    var body: some View {
        Image(systemName: imageSystemName)
            .foregroundColor(.white)
            .background(GeometryReader { proxy in
                Color.clear.preference(key: WidthKey.self, value: proxy.size.width)
            })
            .onPreferenceChange(WidthKey.self) {
                self.width = ($0 ?? 0) + 16
            }
            .frame(width: width, height: width)
            .background(Circle().fill(circleColor))
    }
}

struct WidthKey: PreferenceKey {
    static let defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

struct ImageWithCircle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ImageWithCircle(circleColor: .red, imageSystemName: "arrow.up")
                .previewLayout(PreviewLayout.sizeThatFits)
        }
    }
}
