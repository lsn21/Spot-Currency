//
//  MarketOverviewView.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import SwiftUI

@MainActor
struct MarketOverviewView: View {
    @StateObject private var viewModel: MarketOverviewViewModel
    @State private var isShowingErrorAlert = false

    init(viewModel: MarketOverviewViewModel? = nil) {
        // Создаем viewModel асинхронно на главном акторе
        if let viewModel = viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            // Используем стандартный сервис по умолчанию
            _viewModel = StateObject(wrappedValue: MarketOverviewViewModel(
                marketDataService: BinanceMarketDataService.shared,
                liveUpdateInterval: 5.0
            ))
        }
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Spot Markets")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        refreshIndicator
                    }
                }
        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            isShowingErrorAlert = newValue != nil
        }
        .alert("Ошибка загрузки", isPresented: $isShowingErrorAlert) {
            Button("Повторить") {
                Task { await viewModel.refreshPairs() }
            }
            Button("Отмена", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Не удалось загрузить данные.")
        }
    }

    private var content: some View {
        Group {
            if viewModel.currencyPairs.isEmpty && viewModel.isLoading {
                ProgressView("Loading Markets...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.filteredPairs) { pair in
                    NavigationLink(value: pair) {
                        PairRowView(pair: pair)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $viewModel.searchText, prompt: "Search pairs")
                .refreshable {
                    await viewModel.refreshPairs()
                }
                .navigationDestination(for: CurrencyPair.self) { pair in
                    InstrumentDetailView(pair: pair)
                }
            }
        }
    }

    @ViewBuilder
    private var refreshIndicator: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let date = viewModel.lastUpdatedAt {
            Text(date, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            Button {
                Task { await viewModel.refreshPairs() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
}

@MainActor
struct MarketOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        MarketOverviewView(viewModel: MarketOverviewViewModel(marketDataService: BinanceMarketDataService.shared))
    }
}

