//
//  AddCurrencyView.swift
//  Converter
//

import SwiftUI

struct AddCurrencyView: View {
    @Environment(CurrencyStore.self) private var currencyStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredRates: [Rate] {
        if searchText.isEmpty {
            return currencyStore.allRates
        }
        let query = searchText.lowercased()
        return currencyStore.allRates.filter {
            $0.currency.code.lowercased().contains(query) ||
            $0.currency.title.lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRates) { rate in
                    Button {
                        currencyStore.toggleCurrency(rate.currency.code)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(rate.currency.title)
                                Text(rate.currency.code)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if currencyStore.isSelected(rate.currency.code) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                                    .font(.body.weight(.semibold))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("Add")
            .searchable(text: $searchText, prompt: "Search currencies")
            .searchPresentationToolbarBehavior(.avoidHidingContent)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .tint(.primary)
                }
            }
        }
        .presentationBackground(.ultraThinMaterial)
    }
}

#Preview {
    AddCurrencyView()
        .environment(CurrencyStore())
}
