//
//  MarketModels.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//

import Foundation

struct CurrencyPair: Identifiable, Hashable {
    /// Display symbol, e.g. "BTCUSDT"
    var id: String { symbol }
    let symbol: String
    let currentPrice: Double
    let change: Double
    let changePercent: Double
    let lastUpdated: Date
}

struct Candle: Identifiable, Hashable {
    let id = UUID()
    let timestamp: Date
    let open: Double
    let close: Double
    let high: Double
    let low: Double
    let volume: Double
}

struct OrderBookItem: Identifiable, Hashable {
    let id = UUID()
    let price: Double
    let amount: Double
    let isBid: Bool
}

struct Trade: Identifiable, Hashable {
    let id = UUID()
    let price: Double
    let amount: Double
    let date: Date
    let isBuy: Bool
}

struct InstrumentStats {
    let high: Double
    let low: Double
    let volume: Double
}

enum Timeframe: String, CaseIterable, Identifiable {
    case oneMinute = "1m"
    case fiveMinutes = "5m"
    case fifteenMinutes = "15m"
    case oneHour = "1h"
    case oneDay = "1d"

    var id: String { rawValue }

    /// Human‑readable label for UI
    var title: String {
        switch self {
        case .oneMinute: return "1m"
        case .fiveMinutes: return "5m"
        case .fifteenMinutes: return "15m"
        case .oneHour: return "1h"
        case .oneDay: return "1d"
        }
    }

    /// Binance interval string
    var binanceInterval: String { rawValue }

    /// Number of points to request for charts
    var limit: Int {
        switch self {
        case .oneMinute: return 60   // 1h of 1m candles
        case .fiveMinutes: return 120 // 10h
        case .fifteenMinutes: return 120 // 30h
        case .oneHour: return 168 // 1 week
        case .oneDay: return 180 // ~6 months
        }
    }
}

extension CurrencyPair {
    static func == (lhs: CurrencyPair, rhs: CurrencyPair) -> Bool {
        lhs.symbol == rhs.symbol
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
}

