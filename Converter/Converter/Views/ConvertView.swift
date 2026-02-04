//
//  ConvertView.swift
//  Converter
//

import SwiftUI

struct ConvertView: View {
    @Environment(CurrencyStore.self) private var currencyStore
    @Environment(SettingsStore.self) private var settingsStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(currencyStore.currencies) { currency in
                    CurrencyRow(
                        currency: currency,
                        value: currencyStore.getValue(for: currency),
                        isActive: currencyStore.activeCurrencyId == currency.id,
                        accentColor: settingsStore.accentColor.color
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        currencyStore.setActive(currency)
                    }
                }
            }
            .navigationTitle("Convert")
            .refreshable {
                await currencyStore.refresh()
            }
        }
    }
}

struct CurrencyRow: View {
    let currency: Currency
    let value: Double
    let isActive: Bool
    let accentColor: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(currency.name)
                    .font(.body)
                Text(currency.code)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(currency.formatValue(value))
                .font(.body.monospacedDigit())
                .foregroundStyle(isActive ? .white : .primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isActive ? accentColor : .clear, in: .capsule)
        }
    }
}

#Preview {
    ConvertView()
        .environment(CurrencyStore())
        .environment(SettingsStore())
}
