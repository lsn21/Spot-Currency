//
//  MarketDataService.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import Foundation

protocol MarketDataService {
    func fetchCurrencyPairs() async throws -> [CurrencyPair]
    func fetchCandles(for symbol: String, timeframe: Timeframe) async throws -> [Candle]
    func fetchOrderBook(for symbol: String) async throws -> [OrderBookItem]
    func fetchTrades(for symbol: String) async throws -> [Trade]
}

enum MarketDataError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case unknown
}

// MARK: - Binance implementation

actor BinanceMarketDataService: MarketDataService {
    static let shared = BinanceMarketDataService()

    private let baseURL = URL(string: "https://api.binance.com")!
    /// Restrict to a small set of popular symbols for the overview screen
    private let trackedSymbols: [String] = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "BNBUSDT", "XRPUSDT"]

    private init() {}

    // MARK: Public API

    func fetchCurrencyPairs() async throws -> [CurrencyPair] {
        let endpoint = URL(string: "/api/v3/ticker/24hr", relativeTo: baseURL)
        guard let url = endpoint else { throw MarketDataError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MarketDataError.requestFailed
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        let tickers: BinanceTickerResponse
        do {
            tickers = try decoder.decode(BinanceTickerResponse.self, from: data)
        } catch {
            throw MarketDataError.decodingFailed
        }

        let filtered = tickers.filter { trackedSymbols.contains($0.symbol) }
        let now = Date()

        return filtered.compactMap { ticker in
            guard
                let lastPrice = ticker.lastPriceDouble,
                let change = ticker.priceChangeDouble,
                let changePercent = ticker.changePercentDouble
            else { return nil }

            return CurrencyPair(
                symbol: ticker.symbol,
                currentPrice: lastPrice,
                change: change,
                changePercent: changePercent,
                lastUpdated: now
            )
        }
        .sorted { $0.symbol < $1.symbol }
    }

    func fetchCandles(for symbol: String, timeframe: Timeframe) async throws -> [Candle] {
        var components = URLComponents(url: baseURL.appendingPathComponent("/api/v3/klines"),
                                       resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "interval", value: timeframe.binanceInterval),
            URLQueryItem(name: "limit", value: String(timeframe.limit))
        ]
        guard let url = components?.url else { throw MarketDataError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MarketDataError.requestFailed
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        let klines: [BinanceKline]
        do {
            klines = try decoder.decode([BinanceKline].self, from: data)
        } catch {
            throw MarketDataError.decodingFailed
        }

        return klines.map {
            Candle(
                timestamp: Date(timeIntervalSince1970: $0.closeTime / 1000),
                open: $0.open,
                close: $0.close,
                high: $0.high,
                low: $0.low,
                volume: $0.volume
            )
        }
        .sorted { $0.timestamp < $1.timestamp }
    }

    func fetchOrderBook(for symbol: String) async throws -> [OrderBookItem] {
        var components = URLComponents(url: baseURL.appendingPathComponent("/api/v3/depth"),
                                       resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "limit", value: "20")
        ]
        guard let url = components?.url else { throw MarketDataError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MarketDataError.requestFailed
        }

        let decoder = JSONDecoder()
        let depth: BinanceDepthResponse
        do {
            depth = try decoder.decode(BinanceDepthResponse.self, from: data)
        } catch {
            throw MarketDataError.decodingFailed
        }

        var items: [OrderBookItem] = []

        for bid in depth.bids {
            if bid.count >= 2,
               let price = Double(bid[0]),
               let qty = Double(bid[1]) {
                items.append(OrderBookItem(price: price, amount: qty, isBid: true))
            }
        }

        for ask in depth.asks {
            if ask.count >= 2,
               let price = Double(ask[0]),
               let qty = Double(ask[1]) {
                items.append(OrderBookItem(price: price, amount: qty, isBid: false))
            }
        }

        return items
    }

    func fetchTrades(for symbol: String) async throws -> [Trade] {
        var components = URLComponents(url: baseURL.appendingPathComponent("/api/v3/trades"),
                                       resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "limit", value: "40")
        ]
        guard let url = components?.url else { throw MarketDataError.invalidURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MarketDataError.requestFailed
        }

        let decoder = JSONDecoder()
        let tradesResponse: BinanceTradesResponse
        do {
            tradesResponse = try decoder.decode(BinanceTradesResponse.self, from: data)
        } catch {
            throw MarketDataError.decodingFailed
        }

        return tradesResponse.map { trade in
            let price = Double(trade.price) ?? 0
            let qty = Double(trade.qty) ?? 0
            let date = Date(timeIntervalSince1970: trade.time / 1000)
            let isBuy = !trade.isBuyerMaker
            return Trade(price: price, amount: qty, date: date, isBuy: isBuy)
        }
        .sorted { $0.date > $1.date }
    }
}


