//
//  SettingsStore.swift
//  Converter
//

import SwiftUI

enum NumberFormatOption: String, CaseIterable, Identifiable {
    case system = "System"
    case commaDot = "1,234.56"
    case dotComma = "1.234,56"
    case spaceComma = "1 234,56"

    var id: String { rawValue }

    var resolved: NumberFormatOption {
        guard self == .system else { return self }
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        let decimal = formatter.decimalSeparator ?? "."
        let grouping = formatter.groupingSeparator ?? ","
        switch (decimal, grouping) {
        case (".", ","): return .commaDot
        case (",", "."): return .dotComma
        case (",", "\u{00A0}"), (",", " "): return .spaceComma
        default:
            return .commaDot
        }
    }

    var decimalSeparator: String {
        switch resolved {
        case .commaDot: return "."
        case .dotComma, .spaceComma: return ","
        case .system: return "."
        }
    }

    var groupingSeparator: String? {
        switch resolved {
        case .commaDot: return ","
        case .dotComma: return "."
        case .spaceComma: return "\u{00A0}"
        case .system: return nil
        }
    }
}

enum ThemeMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AccentColorOption: String, CaseIterable, Identifiable {
    case blue = "Blue"
    case purple = "Purple"
    case fuchsia = "Fuchsia"
    case red = "Red"
    case orange = "Orange"
    case green = "Green"
    case teal = "Teal"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: return Color(hex: "#1976d2")
        case .purple: return Color(hex: "#7b1fa2")
        case .fuchsia: return Color(hex: "#ff00ff")
        case .red: return Color(hex: "#c10015")
        case .orange: return Color(hex: "#e65100")
        case .green: return Color(hex: "#2e7d32")
        case .teal: return Color(hex: "#00897b")
        }
    }
}

@Observable
class SettingsStore {
    private enum Keys {
        static let themeMode = "settings.themeMode"
        static let accentColor = "settings.accentColor"
        static let numberFormat = "settings.numberFormat"
    }

    private var isLoading = false

    var themeMode: ThemeMode = .system {
        didSet { if !isLoading { save() } }
    }
    var accentColor: AccentColorOption = .blue {
        didSet { if !isLoading { save() } }
    }
    var numberFormat: NumberFormatOption = .system {
        didSet { if !isLoading { save() } }
    }

    init() {
        load()
    }

    private func load() {
        isLoading = true
        let defaults = UserDefaults.standard

        if let themeModeRaw = defaults.string(forKey: Keys.themeMode),
           let themeMode = ThemeMode(rawValue: themeModeRaw) {
            self.themeMode = themeMode
        }

        if let accentColorRaw = defaults.string(forKey: Keys.accentColor),
           let accentColor = AccentColorOption(rawValue: accentColorRaw) {
            self.accentColor = accentColor
        }

        if let numberFormatRaw = defaults.string(forKey: Keys.numberFormat),
           let numberFormat = NumberFormatOption(rawValue: numberFormatRaw) {
            self.numberFormat = numberFormat
        }
        isLoading = false
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(themeMode.rawValue, forKey: Keys.themeMode)
        defaults.set(accentColor.rawValue, forKey: Keys.accentColor)
        defaults.set(numberFormat.rawValue, forKey: Keys.numberFormat)
    }

    func resetToDefaults() {
        themeMode = .system
        accentColor = .blue
        numberFormat = .system
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
