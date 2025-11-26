//
//  MarketOverviewViewModel.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MarketOverviewViewModel: ObservableObject {
    @Published private(set) var currencyPairs: [CurrencyPair] = []
    @Published var searchText: String = ""
    @Published private(set) var isLoading = false
    @Published private(set) var lastUpdatedAt: Date?
    @Published var errorMessage: String?

    private let marketDataService: any MarketDataService
    private var liveTimer: AnyCancellable?
    private let updateInterval: TimeInterval

    init(marketDataService: any MarketDataService = BinanceMarketDataService.shared,
         liveUpdateInterval: TimeInterval = 5) {
        self.marketDataService = marketDataService
        self.updateInterval = liveUpdateInterval
    }

    var filteredPairs: [CurrencyPair] {
        guard !searchText.isEmpty else { return currencyPairs }
        return currencyPairs.filter { $0.symbol.lowercased().contains(searchText.lowercased()) }
    }

    func onAppear() {
        if currencyPairs.isEmpty {
            Task { await refreshPairs(animated: false) }
        }
        startLiveUpdatesIfNeeded()
    }

    func onDisappear() {
        liveTimer?.cancel()
        liveTimer = nil
    }

    func refreshPairs(animated: Bool = true) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let pairs = try await marketDataService.fetchCurrencyPairs()
            errorMessage = nil
            if animated {
                withAnimation(.easeInOut(duration: 0.25)) {
                    currencyPairs = pairs
                }
            } else {
                currencyPairs = pairs
            }
            lastUpdatedAt = Date()
        } catch {
            errorMessage = "Не удалось загрузить рынки. Проверьте подключение к сети и попробуйте еще раз."
            print("Failed to fetch pairs: \(error)")
        }
    }

    private func startLiveUpdatesIfNeeded() {
        guard liveTimer == nil else { return }

        liveTimer = Timer.publish(every: updateInterval,
                                  on: .main,
                                  in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.refreshPairs(animated: true) }
            }
    }
}

