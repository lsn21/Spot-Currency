//
//  CandlestickChartView.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//

import SwiftUI
import Charts

struct CandlestickChartView: View {
    let candles: [Candle]

    var body: some View {
        Chart(candles) { candle in
            RuleMark(x: .value("Time", candle.timestamp),
                     yStart: .value("Low", candle.low),
                     yEnd: .value("High", candle.high))
                .foregroundStyle(.secondary.opacity(0.4))

            BarMark(x: .value("Time", candle.timestamp),
                    yStart: .value("Open", min(candle.open, candle.close)),
                    yEnd: .value("Close", max(candle.open, candle.close)),
                    width: .fixed(8))
                .foregroundStyle(candle.close >= candle.open ? Color.green : Color.red)
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 240)
        .padding(.vertical, 8)
    }
}

struct CandlestickChartView_Previews: PreviewProvider {
    static var previews: some View {
        CandlestickChartView(candles: [
            Candle(timestamp: .now, open: 1.0, close: 1.03, high: 1.05, low: 0.99, volume: 120),
            Candle(timestamp: .now.addingTimeInterval(-3600), open: 1.01, close: 0.98, high: 1.04, low: 0.97, volume: 140)
        ])
        .padding()
    }
}

