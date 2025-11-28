//
//  PairRowView.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import SwiftUI

struct PairRowView: View {
    let pair: CurrencyPair

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(pair.formattedSymbol)
                    .font(.headline)
                Text("Updated \(relativeDateString(from: pair.lastUpdated))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(pair.formattedPrice)
                    .font(.headline)
                Text(pair.formattedChange)
                    .font(.caption)
                    .foregroundStyle(pair.trendColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(pair.trendColor.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.vertical, 4)
    }

    private func relativeDateString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}

struct PairRowView_Previews: PreviewProvider {
    static var previews: some View {
        PairRowView(pair: CurrencyPair(symbol: "EUR/USD",
                                       currentPrice: 1.0854,
                                       change: -0.0005,
                                       changePercent: -0.12,
                                       lastUpdated: .now))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

