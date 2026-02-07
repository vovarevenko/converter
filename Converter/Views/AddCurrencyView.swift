//
//  AddCurrencyView.swift
//  Converter
//

import SwiftUI

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

#Preview {
    AddCurrencyView()
}
