//
//  ConvertView.swift
//  Converter
//

import SwiftUI

struct ConvertView: View {
    @Environment(CurrencyStore.self) private var currencyStore
    @Environment(SettingsStore.self) private var settingsStore
    @State private var isEditMode = false
    @State private var selectedRateForInput: Rate?

    var body: some View {
        NavigationStack {
            ZStack {
                if currencyStore.isLoading && currencyStore.rates.isEmpty {
                    ProgressView()
                } else if let errorMessage = currencyStore.errorMessage, currencyStore.rates.isEmpty {
                    ContentUnavailableView {
                        Label("Connection Error", systemImage: "wifi.slash")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Try Again") {
                            Task { await currencyStore.refresh() }
                        }
                    }
                } else if !currencyStore.allRates.isEmpty && currencyStore.rates.isEmpty {
                    ContentUnavailableView {
                        Label("No Currencies", systemImage: "plus.circle")
                    } description: {
                        Text("Tap + to add currencies")
                    }
                } else {
                    List {
                        ForEach(currencyStore.rates) { rate in
                            CurrencyRow(
                                rate: rate,
                                value: currencyStore.getValue(for: rate),
                                isActive: currencyStore.activeCurrencyCode == rate.currency.code,
                                accentColor: settingsStore.accentColor.color,
                                isEditMode: isEditMode,
                                onTap: { selectedRateForInput = rate },
                                onDelete: { currencyStore.deleteCurrency(rate) }
                            )
                        }
                        .onMove { from, to in
                            currencyStore.moveCurrency(from: from, to: to)
                        }
                    }
                    .refreshable {
                        await currencyStore.refresh()
                    }
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
            .sheet(item: $selectedRateForInput) { rate in
                NumericKeyboardView(rate: rate)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct CurrencyRow: View {
    let rate: Rate
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
                Text(rate.currency.title)
                Text(rate.currency.code)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, isEditMode ? 8 : 0)

            Spacer()

            ZStack(alignment: .trailing) {
                Text(rate.currency.formatValue(value))
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
