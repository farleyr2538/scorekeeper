//
//  SettingsView.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 06/11/2026.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(SettingsKey.defaultHalving) private var defaultHalving : Bool = true
    @AppStorage(SettingsKey.defaultLowestWins) private var defaultLowestWins : Bool = true
    @AppStorage(SettingsKey.showScoreNeededToHalve) private var showScoreNeededToHalve : Bool = false
    @AppStorage(SettingsKey.highlightZeros) private var highlightZeros : Bool = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Halving", isOn: $defaultHalving)
                Toggle("Lowest score wins", isOn: $defaultLowestWins)
            } header: {
                Text("New game defaults")
            } footer: {
                Text("Halving: if a player hits a multiple of 50, half their score.")
            }
            
            Section {
                Toggle("Highlight zeros", isOn: $highlightZeros)
            } header: {
                Text("Scores")
            } footer: {
                Text("Show scores of 0 in orange, after the first round.")
            }
            
            Section {
                Toggle("Show score needed to half", isOn: $showScoreNeededToHalve)
            } header: {
                Text("Leaderboard")
            } footer: {
                Text("Only shown in games with halving on.")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
