//
//  ConverterApp.swift
//  Converter
//

import SwiftUI

@main
struct ConverterApp: App {
    @State private var currencyStore = CurrencyStore()
    @State private var settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(currencyStore)
                .environment(settingsStore)
                .preferredColorScheme(settingsStore.themeMode.colorScheme)
        }
    }
}
