//
//  InstrumentDetailView.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//

import SwiftUI

@MainActor
struct InstrumentDetailView: View {
    @StateObject private var viewModel: InstrumentDetailViewModel
    @State private var selectedSection: DetailSection = .orderBook
    @State private var isShowingErrorAlert = false

    private enum DetailSection: String, CaseIterable, Identifiable {
        case orderBook = "Order Book"
        case trades = "Trade History"

        var id: String { rawValue }
    }

    init(pair: CurrencyPair,
         marketDataService: any MarketDataService = BinanceMarketDataService.shared) {
        _viewModel = StateObject(wrappedValue: InstrumentDetailViewModel(currencyPair: pair,
                                                                         marketDataService: marketDataService))
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    chartSection
                    statsSection
                    segmentedSection
                }
                .padding()
            }
            .navigationTitle(viewModel.latestPair.formattedSymbol)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.onAppear() }
            .onDisappear { viewModel.onDisappear() }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                isShowingErrorAlert = newValue != nil
            }
            .alert("Ошибка", isPresented: $isShowingErrorAlert) {
                Button("Закрыть", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "Не удалось загрузить данные.")
            }
        } else {
            // Fallback on earlier versions
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.latestPair.formattedPrice)
                .font(.system(size: 34, weight: .bold))
            Text(viewModel.latestPair.formattedChange)
                .font(.subheadline)
                .foregroundStyle(viewModel.latestPair.trendColor)
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            TimeframePicker(selection: $viewModel.selectedTimeframe)
            if viewModel.candles.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                CandlestickChartView(candles: viewModel.candles)
            }
        }
    }

    private var statsSection: some View {
        InstrumentStatsView(stats: viewModel.stats, quote: quoteCurrencyPrefix)
    }

    private var segmentedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Section", selection: $selectedSection) {
                ForEach(DetailSection.allCases) { section in
                    Text(section.rawValue).tag(section)
                }
            }
            .pickerStyle(.segmented)

            switch selectedSection {
            case .orderBook:
                if viewModel.bids.isEmpty && viewModel.asks.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    OrderBookView(bids: viewModel.bids, asks: viewModel.asks)
                }
            case .trades:
                if viewModel.trades.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    TradeHistoryView(trades: viewModel.trades)
                }
            }
        }
    }

    private var quoteCurrencyPrefix: String {
        if viewModel.latestPair.symbol.contains("USD") {
            return "$"
        }
        return ""
    }
}

@MainActor
struct InstrumentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let pair = CurrencyPair(symbol: "BTCUSDT",
                                currentPrice: 1.0854,
                                change: 0.001,
                                changePercent: 0.12,
                                lastUpdated: .now)
        InstrumentDetailView(pair: pair, marketDataService: BinanceMarketDataService.shared)
    }
}

