//
//  ContentView.swift
//  Converter
//

import SwiftUI

struct ContentView: View {
    @Environment(SettingsStore.self) private var settingsStore
    @State private var selectedTab: TabDestination = .convert
    @State private var showingAddSheet = false

    private var isEditMode: Bool {
        selectedTab == .edit
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Convert", systemImage: "arrow.left.arrow.right", value: .convert) {
                ConvertView(isEditMode: false)
            }

            Tab("Edit", systemImage: "list.bullet", value: .edit) {
                ConvertView(isEditMode: true)
            }

            Tab("Settings", systemImage: "gear", value: .settings) {
                SettingsView()
            }

            Tab("Add", systemImage: "plus", value: TabDestination.add, role: .search) {
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
}

enum TabDestination: Hashable {
    case convert
    case edit
    case settings
    case add
}

#Preview {
    ContentView()
        .environment(CurrencyStore())
        .environment(SettingsStore())
}
