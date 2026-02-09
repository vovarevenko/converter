//
//  SettingsView.swift
//  Converter
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settingsStore
    @State private var showingResetAlert = false

    var body: some View {
        @Bindable var settings = settingsStore

        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $settings.themeMode) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .id(settingsStore.accentColor)
                }

                Section("Accent Color") {
                    ForEach(AccentColorOption.allCases) { option in
                        HStack {
                            Circle()
                                .fill(option.color)
                                .frame(width: 24, height: 24)

                            Text(option.rawValue)

                            Spacer()

                            if settingsStore.accentColor == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(settingsStore.accentColor.color)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            settings.accentColor = option
                        }
                        .accessibilityLabel(option.rawValue)
                        .accessibilityValue(settingsStore.accentColor == option ? "Selected" : "")
                    }
                }

                Section("Number Format") {
                    ForEach(NumberFormatOption.allCases) { option in
                        HStack {
                            Text(option.rawValue)

                            Spacer()

                            if settingsStore.numberFormat == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(settingsStore.accentColor.color)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            settings.numberFormat = option
                        }
                        .accessibilityLabel(option.rawValue)
                        .accessibilityValue(settingsStore.numberFormat == option ? "Selected" : "")
                    }
                }

                Section {
                    Button("Reset to Defaults", role: .destructive) {
                        showingResetAlert = true
                    }
                }
            }
            .navigationTitle("Settings")
            .tint(settingsStore.accentColor.color)
            .alert("Reset Settings", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    settingsStore.resetToDefaults()
                }
            } message: {
                Text("This will reset all settings to their default values.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(SettingsStore())
}
