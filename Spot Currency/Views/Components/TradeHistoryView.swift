//
//  TradeHistoryView.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import SwiftUI

struct TradeHistoryView: View {
    let trades: [Trade]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(trades.prefix(20)) { trade in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trade.price.currencyString(maximumFractionDigits: 5))
                            .font(.headline)
                            .foregroundStyle(trade.isBuy ? Color.green : Color.red)
                        Text(trade.date, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(trade.amount.currencyString(maximumFractionDigits: 2))")
                            .font(.subheadline)
                        Text(trade.isBuy ? "Buy" : "Sell")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background((trade.isBuy ? Color.green : Color.red).opacity(0.15),
                                        in: Capsule())
                    }
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

struct TradeHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TradeHistoryView(trades: (0..<5).map { _ in Trade(price: Double.random(in: 1...2),
                                                          amount: Double.random(in: 10...100),
                                                          date: .now,
                                                          isBuy: Bool.random()) })
            .padding()
    }
}

