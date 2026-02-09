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
    @State private var showingAddSheet = false
    @State private var copiedCurrencyCode: String?

    var body: some View {
        NavigationStack {
            ZStack {
                if currencyStore.isLoading && currencyStore.rates.isEmpty {
                    ProgressView()
                } else if currencyStore.errorMessage != nil, currencyStore.rates.isEmpty {
                    ContentUnavailableView {
                        Label("Connection Error", systemImage: "wifi.slash")
                    } description: {
                        Text("Failed to load exchange rates.\nCheck your connection and try again.")
                    } actions: {
                        Button {
                            Task { await currencyStore.refresh() }
                        } label: {
                            Group {
                                if currencyStore.isLoading {
                                    ProgressView()
                                } else {
                                    Text("Try Again")
                                }
                            }
                            .frame(minWidth: 120)
                        }
                        .disabled(currencyStore.isLoading)
                    }
                } else if !currencyStore.allRates.isEmpty && currencyStore.rates.isEmpty {
                    ContentUnavailableView {
                        Label("No Currencies", systemImage: "plus.circle")
                    } description: {
                        Text("Add currencies to start converting")
                    } actions: {
                        Button("Add Currencies") {
                            showingAddSheet = true
                        }
                    }
                } else {
                    List {
                        ForEach(currencyStore.rates) { rate in
                            let formattedValue = rate.currency.formatValue(
                                currencyStore.getValue(for: rate),
                                numberFormat: settingsStore.numberFormat
                            )
                            CurrencyRow(
                                rate: rate,
                                formattedValue: formattedValue,
                                isActive: currencyStore.activeCurrencyCode == rate.currency.code,
                                accentColor: settingsStore.accentColor.color,
                                isEditMode: isEditMode,
                                isCopied: copiedCurrencyCode == rate.currency.code,
                                onTap: { selectedRateForInput = rate },
                                onDelete: { currencyStore.deleteCurrency(code: rate.currency.code) },
                                onCopy: { copyValue(formattedValue, currencyCode: rate.currency.code) }
                            )
                        }
                        .onMove { from, to in
                            currencyStore.moveCurrency(from: from, to: to)
                        }

                        if let lastRefreshedAt = currencyStore.lastRefreshedAt {
                            Section {
                                Text("Updated \(lastRefreshedAt, format: .relative(presentation: .named))")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .listRowBackground(Color.clear)
                            }
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
                    .accessibilityLabel(isEditMode ? "Done editing" : "Edit currencies")
                }
            }
            .sheet(item: $selectedRateForInput) { rate in
                NumericKeyboardView(rate: rate)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddCurrencyView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func copyValue(_ value: String, currencyCode: String) {
        UIPasteboard.general.string = value
        withAnimation {
            copiedCurrencyCode = currencyCode
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                if copiedCurrencyCode == currencyCode {
                    copiedCurrencyCode = nil
                }
            }
        }
    }
}

struct CurrencyRow: View {
    let rate: Rate
    let formattedValue: String
    let isActive: Bool
    let accentColor: Color
    let isEditMode: Bool
    let isCopied: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let onCopy: () -> Void

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
            .accessibilityLabel("Remove \(rate.currency.title)")

            VStack(alignment: .leading) {
                Text(rate.currency.title)
                Text(rate.currency.code)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, isEditMode ? 8 : 0)

            Spacer()

            ZStack(alignment: .trailing) {
                Group {
                    if isCopied {
                        Label("Copied", systemImage: "checkmark")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(formattedValue)
                            .font(.body.monospacedDigit())
                            .foregroundStyle(isActive ? .white : .primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(isActive ? accentColor : .clear, in: .capsule)
                    }
                }
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
        .onLongPressGesture {
            if !isEditMode {
                onCopy()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(rate.currency.title), \(formattedValue)")
        .accessibilityHint(isEditMode ? "Drag to reorder" : "Tap to edit amount, hold to copy")
        .animation(.easeInOut(duration: 0.2), value: isEditMode)
        .animation(.easeInOut(duration: 0.2), value: isCopied)
    }
}

#Preview {
    ConvertView()
        .environment(CurrencyStore())
        .environment(SettingsStore())
}
