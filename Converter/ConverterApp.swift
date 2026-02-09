//
//  ConverterApp.swift
//  Converter
//

import SwiftUI

@main
struct ConverterApp: App {
    @State private var currencyStore = CurrencyStore()
    @State private var settingsStore = SettingsStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(currencyStore)
                .environment(settingsStore)
                .preferredColorScheme(settingsStore.themeMode.colorScheme)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        Task { await currencyStore.refreshIfNeeded() }
                    }
                }
        }
    }
}
