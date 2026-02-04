//
//  EditView.swift
//  Converter
//

import SwiftUI

struct EditView: View {
    @Environment(CurrencyStore.self) private var currencyStore
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(currencyStore.currencies) { currency in
                    EditCurrencyRow(currency: currency)
                }
            }
            .navigationTitle("Edit")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddCurrencyView()
            }
            .refreshable {
                await currencyStore.refresh()
            }
        }
    }
}

struct AddCurrencyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Add currency")
                .foregroundStyle(.secondary)
            .navigationTitle("Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditCurrencyRow: View {
    let currency: Currency

    var body: some View {
        HStack {
            Button(action: {
                // Delete action placeholder
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
                    .font(.title2)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading) {
                Text(currency.name)
                    .font(.body)
                Text(currency.code)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 8)

            Spacer()

            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
                .font(.title3)
        }
    }
}

#Preview {
    EditView()
        .environment(CurrencyStore())
        .environment(SettingsStore())
}
