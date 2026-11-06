//
//  Constants.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 02/06/2026.
//

import Foundation

let maxPlayers = 8

// UserDefaults keys for app-wide settings
enum SettingsKey {
    static let defaultHalving = "defaultHalving"
    static let defaultLowestWins = "defaultLowestWins"
    static let showScoreNeededToHalve = "showScoreNeededToHalve"
    static let highlightZeros = "highlightZeros"
}
