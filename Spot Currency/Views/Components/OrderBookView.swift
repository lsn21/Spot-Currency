//
//  OrderBookView.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//

import SwiftUI

struct OrderBookView: View {
    let bids: [OrderBookItem]
    let asks: [OrderBookItem]

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            DepthColumn(title: "Bids", levels: bids, tint: .green)
            DepthColumn(title: "Asks", levels: asks, tint: .red)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private struct DepthColumn: View {
        let title: String
        let levels: [OrderBookItem]
        let tint: Color

        var body: some View {
            let maxAmount = levels.map(\.amount).max() ?? 1
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(levels.prefix(10)) { level in
                    let ratio = maxAmount == 0 ? 0 : min(level.amount / maxAmount, 1)
                    HStack {
                        Text(level.price.currencyString(maximumFractionDigits: 5))
                            .font(.caption)
                            .foregroundStyle(tint)
                        Spacer()
                        Text(level.amount.currencyString(maximumFractionDigits: 2))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                    .background(
                        GeometryReader { proxy in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(tint.opacity(0.15))
                                .frame(width: max(proxy.size.width * CGFloat(ratio), 1),
                                       alignment: .leading)
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct OrderBookView_Previews: PreviewProvider {
    static var previews: some View {
        OrderBookView(bids: (0..<10).map { _ in OrderBookItem(price: Double.random(in: 1...2),
                                                               amount: Double.random(in: 10...100),
                                                               isBid: true) },
                      asks: (0..<10).map { _ in OrderBookItem(price: Double.random(in: 1...2),
                                                               amount: Double.random(in: 10...100),
                                                               isBid: false) })
            .padding()
    }
}

