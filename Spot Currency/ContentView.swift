//
//  ContentView.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//

import SwiftUI

@MainActor
struct ContentView: View {
    var body: some View {
        MarketOverviewView()
    }
}

@MainActor
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

