//
//  ContentView.swift
//  Converter
//

import SwiftUI

struct ContentView: View {
    @Environment(SettingsStore.self) private var settingsStore
    @State private var selectedTab: Tab = .convert
    @State private var showingAddSheet = false

    var body: some View {
        TabView(selection: $selectedTab) {
            SwiftUI.Tab("Convert", systemImage: "arrow.left.arrow.right", value: .convert) {
                ConvertView()
            }

            SwiftUI.Tab("Settings", systemImage: "gear", value: .settings) {
                SettingsView()
            }

            SwiftUI.Tab("Add", systemImage: "plus", value: Tab.add, role: .search) {
                Color.clear
            }
        }
        .tint(settingsStore.accentColor.color)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .add {
                showingAddSheet = true
                selectedTab = oldValue
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCurrencyView()
        }
    }

    private enum Tab: Hashable {
        case convert, settings, add
    }
}

#Preview {
    ContentView()
        .environment(CurrencyStore())
        .environment(SettingsStore())
}
