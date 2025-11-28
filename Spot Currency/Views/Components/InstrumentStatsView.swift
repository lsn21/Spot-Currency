//
//  InstrumentStatsView.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import SwiftUI

struct InstrumentStatsView: View {
    let stats: InstrumentStats
    let quote: String

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)],
                  spacing: 12) {
            StatCard(title: "High 24h", value: "\(quote)\(stats.high.currencyString())")
            StatCard(title: "Low 24h", value: "\(quote)\(stats.low.currencyString())")
            StatCard(title: "Volume 24h", value: stats.volume.currencyString(maximumFractionDigits: 2))
        }
    }

    private struct StatCard: View {
        let title: String
        let value: String

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct InstrumentStatsView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentStatsView(stats: InstrumentStats(high: 1.12, low: 1.02, volume: 1500),
                            quote: "$")
            .padding()
    }
}

