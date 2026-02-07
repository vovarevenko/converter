//
//  ConverterApp.swift
//  Converter
//

import SwiftUI

@main
struct ConverterApp: App {
    @State private var currencyStore = CurrencyStore()
    @State private var settingsStore = SettingsStore()

    init() {
        cleanUpLegacyData()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(currencyStore)
                .environment(settingsStore)
                .preferredColorScheme(settingsStore.themeMode.colorScheme)
        }
    }

    private func cleanUpLegacyData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "currency.activeCurrencyCode")
        defaults.removeObject(forKey: "currency.activeValue")
    }
}
