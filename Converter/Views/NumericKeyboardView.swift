//
//  NumericKeyboardView.swift
//  Converter
//

import SwiftUI

struct NumericKeyboardView: View {
    let rate: Rate
    @Environment(CurrencyStore.self) private var currencyStore
    @Environment(SettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var inputText = ""

    private var resolvedFormat: NumberFormatOption {
        settingsStore.numberFormat.resolved
    }

    private var displayText: String {
        let raw = inputText.isEmpty ? "0" : inputText
        let parts = raw.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        let integerPart = String(parts[0])
        let decimalPart = parts.count > 1 ? String(parts[1]) : nil

        var formattedInteger = integerPart
        if let grouping = resolvedFormat.groupingSeparator, integerPart.count > 3 {
            var result = ""
            for (i, char) in integerPart.reversed().enumerated() {
                if i > 0 && i % 3 == 0 { result = grouping + result }
                result = String(char) + result
            }
            formattedInteger = result
        }

        if let decimalPart {
            return "\(formattedInteger)\(resolvedFormat.decimalSeparator)\(decimalPart) \(rate.currency.symbol)"
        }
        return "\(formattedInteger) \(rate.currency.symbol)"
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    }

    private var buttons: [KeypadButton] {
        [
            .digit("7"), .digit("8"), .digit("9"),
            .digit("4"), .digit("5"), .digit("6"),
            .digit("1"), .digit("2"), .digit("3"),
            .delete,     .digit("0"), .decimal
        ]
    }

    var body: some View {
        VStack(spacing: 20) {
            // Currency header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(rate.currency.title)
                        .font(.headline)
                    Text(rate.currency.code)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                DismissButton()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            // Value display
            Text(displayText)
                .font(.system(size: 80, weight: .medium, design: .rounded))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

            // Keypad grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(buttons) { button in
                    KeypadButtonView(
                        button: button,
                        decimalSeparator: resolvedFormat.decimalSeparator,
                        decimalDisabled: button == .decimal && rate.currency.decimals == 0
                    ) {
                        handleTap(button)
                    }
                }
            }
            .padding(.horizontal, 24)

            // Convert button
            Button {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                let amount = Double(inputText) ?? 0
                if amount > 0 {
                    currencyStore.convert(from: rate.currency.code, amount: amount)
                }
                dismiss()
            } label: {
                Text("Convert")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(settingsStore.accentColor.color)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
    }

    private func handleTap(_ button: KeypadButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        switch button {
        case .digit(let d):
            if inputText == "0" && d == "0" { return }
            if inputText == "0" { inputText = d; return }
            if let dotIndex = inputText.firstIndex(of: ".") {
                let decimalsEntered = inputText.distance(from: inputText.index(after: dotIndex), to: inputText.endIndex)
                if decimalsEntered >= rate.currency.decimals { return }
            }
            inputText.append(d)

        case .decimal:
            guard rate.currency.decimals > 0 else { return }
            if inputText.contains(".") { return }
            if inputText.isEmpty { inputText = "0" }
            inputText.append(".")

        case .delete:
            if !inputText.isEmpty {
                inputText.removeLast()
            }
        }
    }
}

// MARK: - KeypadButton

private enum KeypadButton: Identifiable, Equatable {
    case digit(String)
    case decimal
    case delete

    var id: String {
        switch self {
        case .digit(let d): return "digit_\(d)"
        case .decimal: return "decimal"
        case .delete: return "delete"
        }
    }
}

// MARK: - KeypadButtonView

private struct KeypadButtonView: View {
    let button: KeypadButton
    let decimalSeparator: String
    let decimalDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                switch button {
                case .digit(let d):
                    Text(d)
                        .font(.title2.weight(.medium))
                case .decimal:
                    Text(decimalSeparator)
                        .font(.title2.weight(.medium))
                case .delete:
                    Image(systemName: "delete.backward")
                        .font(.title3)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(button == .decimal && decimalDisabled)
        .opacity(button == .decimal && decimalDisabled ? 0.3 : 1)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        switch button {
        case .digit(let d): return d
        case .decimal: return "Decimal separator"
        case .delete: return "Delete"
        }
    }
}
