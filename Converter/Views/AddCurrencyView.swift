//
//  AddCurrencyView.swift
//  Converter
//

import SwiftUI

struct AddCurrencyView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Add")
                    .font(.headline)

                Spacer()

                DismissButton()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            Text("Add currency")
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

#Preview {
    AddCurrencyView()
}
