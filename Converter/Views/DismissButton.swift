//
//  DismissButton.swift
//  Converter
//

import SwiftUI

struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    var systemImage: String = "xmark"

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .tint(.secondary)
    }
}
