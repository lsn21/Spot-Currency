//
//  TimeframePicker.swift
//  Spot Currency
//
//  Created by Siarhei Lukyanau on 25.11.25.
//

import SwiftUI

struct TimeframePicker: View {
    @Binding var selection: Timeframe

    var body: some View {
        Picker("Timeframe", selection: $selection) {
            ForEach(Timeframe.allCases) { timeframe in
                Text(timeframe.title).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct TimeframePicker_Previews: PreviewProvider {
    static var previews: some View {
        TimeframePicker(selection: .constant(.oneDay))
            .padding()
    }
}

