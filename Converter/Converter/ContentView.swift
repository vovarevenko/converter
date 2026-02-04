//
//  ContentView.swift
//  Converter
//

import SwiftUI

struct ContentView: View {
    @Environment(SettingsStore.self) private var settingsStore

    var body: some View {
        TabView {
            ConvertView()
                .tabItem {
                    Label("Convert", systemImage: "arrow.left.arrow.right")
                }

            EditView()
                .tabItem {
                    Label("Edit", systemImage: "pencil")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }

            AddPlaceholderView()
                .tabItem {
                    Label("Add", systemImage: "plus")
                }
        }
        .tint(settingsStore.accentColor.color)
    }
}

struct AddPlaceholderView: View {
    var body: some View {
        NavigationStack {
            Text("Add currency")
                .foregroundStyle(.secondary)
                .navigationTitle("Add")
        }
    }
}

#Preview {
    ContentView()
        .environment(CurrencyStore())
        .environment(SettingsStore())
}
