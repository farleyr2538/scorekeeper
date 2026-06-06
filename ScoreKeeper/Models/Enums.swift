//
//  Enums.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 05/06/2026.
//

import Foundation

enum FinishedGameTab {
    case stats
    case scoreboard
}

enum StartScoreMode {
    case startAtZero
    case averageScore
}

enum Context {
    case preGame
    case midGame
}

enum GameTab {
    case scoresGridTab
    case leaderboardTab
    case chartTab
}
