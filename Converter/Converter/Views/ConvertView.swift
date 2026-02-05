//
//  ConvertView.swift
//  Converter
//

import SwiftUI

struct ConvertView: View {
    @Environment(CurrencyStore.self) private var currencyStore
    @Environment(SettingsStore.self) private var settingsStore
    @State private var isEditMode = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(currencyStore.currencies) { currency in
                    CurrencyRow(
                        currency: currency,
                        value: currencyStore.getValue(for: currency),
                        isActive: currencyStore.activeCurrencyId == currency.id,
                        accentColor: settingsStore.accentColor.color,
                        isEditMode: isEditMode,
                        onTap: { currencyStore.setActive(currency) },
                        onDelete: { currencyStore.deleteCurrency(currency) }
                    )
                }
                .onMove { from, to in
                    currencyStore.moveCurrency(from: from, to: to)
                }
            }
            .navigationTitle("Convert")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            isEditMode.toggle()
                        }
                    } label: {
                        Image(systemName: isEditMode ? "checkmark" : "pencil")
                    }
                    .tint(.primary)
                }
            }
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
    let isEditMode: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .frame(width: isEditMode ? nil : 0)
            .opacity(isEditMode ? 1 : 0)
            .clipped()

            VStack(alignment: .leading) {
                Text(currency.name)
                Text(currency.code)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, isEditMode ? 8 : 0)

            Spacer()

            ZStack(alignment: .trailing) {
                Text(currency.formatValue(value))
                    .font(.body.monospacedDigit())
                    .foregroundStyle(isActive ? .white : .primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isActive ? accentColor : .clear, in: .capsule)
                    .opacity(isEditMode ? 0 : 1)

                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .opacity(isEditMode ? 1 : 0)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditMode {
                onTap()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isEditMode)
    }
}

#Preview {
    ConvertView()
        .environment(CurrencyStore())
        .environment(SettingsStore())
}
