//
//  Formatters.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import Foundation
import SwiftUI

extension Double {
    func currencyString(maximumFractionDigits: Int = 4) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    func percentString(maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self / 100)) ?? "\(self)%"
    }
}

extension CurrencyPair {
    var formattedPrice: String {
        "$\(currentPrice.currencyString(maximumFractionDigits: 5))"
    }

    var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(change.currencyString(maximumFractionDigits: 5)) (\(sign)\(changePercent.percentString()))"
    }

    var trendColor: Color {
        change >= 0 ? .green : .red
    }
    
    var formattedSymbol: String {
        do {
            let regex = try NSRegularExpression(pattern: "(.*)(USDT)", options: [])
            let formattedString = regex.stringByReplacingMatches(
                in: symbol,
                options: [],
                range: NSRange(location: 0, length: symbol.utf16.count),
                withTemplate: "$1/$2"
            )
            print(formattedString)
            return formattedString
        } catch {
            print("Ошибка при создании регулярного выражения: \(error)")
            return symbol
        }
    }
}

