//
//  InstrumentDetailViewModel.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class InstrumentDetailViewModel: ObservableObject {
    @Published private(set) var candles: [Candle] = []
    @Published private(set) var bids: [OrderBookItem] = []
    @Published private(set) var asks: [OrderBookItem] = []
    @Published private(set) var trades: [Trade] = []
    @Published private(set) var stats = InstrumentStats(high: 0, low: 0, volume: 0)
    @Published private(set) var latestPair: CurrencyPair
    @Published var selectedTimeframe: Timeframe = .oneHour {
        didSet { Task { await refreshCandles() } }
    }
    @Published var errorMessage: String?

    private let marketDataService: any MarketDataService
    private var liveTimer: AnyCancellable?
    private let updateInterval: TimeInterval
    private let symbol: String

    init(currencyPair: CurrencyPair,
         marketDataService: any MarketDataService = BinanceMarketDataService.shared,
         updateInterval: TimeInterval = 7) {
        self.latestPair = currencyPair
        self.symbol = currencyPair.symbol
        self.marketDataService = marketDataService
        self.updateInterval = updateInterval
    }

    func onAppear() {
        Task {
            await refreshPairSnapshot()
            await refreshCandles()
            await refreshOrderBook()
            await refreshTrades()
        }
        startLiveUpdatesIfNeeded()
    }

    func onDisappear() {
        liveTimer?.cancel()
        liveTimer = nil
    }

    private func startLiveUpdatesIfNeeded() {
        guard liveTimer == nil else { return }
        liveTimer = Timer.publish(every: updateInterval,
                                  on: .main,
                                  in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.refreshPairSnapshot()
                    await self.refreshCandles()
                    await self.refreshOrderBook()
                    await self.refreshTrades()
                }
            }
    }

    private func refreshPairSnapshot() async {
        do {
            let pairs = try await marketDataService.fetchCurrencyPairs()
            if let updated = pairs.first(where: { $0.symbol == symbol }) {
                latestPair = updated
            }
        } catch {
            errorMessage = "Не удалось обновить данные инструмента."
            print("Failed to refresh pair snapshot: \(error)")
        }
    }

    private func refreshCandles() async {
        do {
            let candles = try await marketDataService.fetchCandles(for: symbol,
                                                                   timeframe: selectedTimeframe)
            self.candles = candles
            recalculateStats()
        } catch {
            errorMessage = "Не удалось загрузить график."
            print("Failed to load candles: \(error)")
        }
    }

    private func refreshOrderBook() async {
        do {
            let levels = try await marketDataService.fetchOrderBook(for: symbol)
            bids = levels.filter { $0.isBid }.sorted { $0.price > $1.price }
            asks = levels.filter { !$0.isBid }.sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Не удалось загрузить стакан цен."
            print("Failed to load order book: \(error)")
        }
    }

    private func refreshTrades() async {
        do {
            trades = try await marketDataService.fetchTrades(for: symbol)
        } catch {
            errorMessage = "Не удалось загрузить историю сделок."
            print("Failed to load trades: \(error)")
        }
    }

    private func recalculateStats() {
        guard !candles.isEmpty else {
            stats = InstrumentStats(high: 0, low: 0, volume: 0)
            return
        }
        let high = candles.map(\.high).max() ?? 0
        let low = candles.map(\.low).min() ?? 0
        let volume = candles.reduce(0) { $0 + $1.volume }
        stats = InstrumentStats(high: high, low: low, volume: volume)
    }
}

