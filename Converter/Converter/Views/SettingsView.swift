//
//  SettingsView.swift
//  Converter
//

import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settingsStore

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
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environment(SettingsStore())
}
