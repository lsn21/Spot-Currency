//
//  BinanceAPIModels.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//

import Foundation

// MARK: - 24h Ticker

struct BinanceTicker24hr: Codable, Identifiable {
    let symbol: String
    let priceChange: String
    let priceChangePercent: String
    let lastPrice: String
    let volume: String
    let highPrice: String
    let lowPrice: String

    var id: String { symbol }

    var lastPriceDouble: Double? { Double(lastPrice) }
    var priceChangeDouble: Double? { Double(priceChange) }
    var changePercentDouble: Double? { Double(priceChangePercent) }
    var highPriceDouble: Double? { Double(highPrice) }
    var lowPriceDouble: Double? { Double(lowPrice) }
    var volumeDouble: Double? { Double(volume) }
}

typealias BinanceTickerResponse = [BinanceTicker24hr]

// MARK: - Klines (Candles)

struct BinanceKline: Decodable {
    let openTime: TimeInterval
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    let closeTime: TimeInterval

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        openTime = try container.decode(TimeInterval.self)
        let openString = try container.decode(String.self)
        let highString = try container.decode(String.self)
        let lowString = try container.decode(String.self)
        let closeString = try container.decode(String.self)
        let volumeString = try container.decode(String.self)

        // skip: close time, quote asset volume, trades, etc.
        closeTime = try container.decode(TimeInterval.self)
        _ = try? container.decode(String.self) // quote asset volume
        _ = try? container.decode(Int.self) // number of trades
        _ = try? container.decode(String.self) // taker buy base asset volume
        _ = try? container.decode(String.self) // taker buy quote asset volume
        _ = try? container.decode(String.self) // ignore

        open = Double(openString) ?? 0
        high = Double(highString) ?? 0
        low = Double(lowString) ?? 0
        close = Double(closeString) ?? 0
        volume = Double(volumeString) ?? 0
    }
}

// MARK: - Order Book

struct BinanceDepthResponse: Decodable {
    let lastUpdateId: Int
    let bids: [[String]]
    let asks: [[String]]
}

// MARK: - Trades

struct BinanceTrade: Decodable {
    let id: Int
    let price: String
    let qty: String
    let quoteQty: String
    let time: TimeInterval
    let isBuyerMaker: Bool
}

typealias BinanceTradesResponse = [BinanceTrade]

