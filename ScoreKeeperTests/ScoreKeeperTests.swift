//
//  ScoreKeeperTests.swift
//  ScoreKeeperTests
//
//  Created by Rob Farley on 30/05/2026.
//

import Testing
@testable import ScoreKeeper

        
@Suite("Game with seven players")
struct SevenPlayersTests {
    
    let viewModel = ViewModel()
    var game : Game
    
    init() {
        let names = ["Jerry", "Jimmy", "Tony", "Dimitri", "Timmy", "Rob", "Kate"]
        
        var players : [SchemaV5.Player] = []
        names.forEach { name in
            let player = SchemaV5.Player(name: name, scores: [], runningScores: [])
            players.append(player)
        }
        
        self.game = Game(
            players: players, halving: false
        )
    }
    
    @Test func verifySevenPlayerGame() async throws {
        #expect(throws: Never.self) {
            try viewModel.verifyGame(game: game)
        }
    }
    
    @Test func addRoundToSevenPlayerGame() async throws {
        #expect(throws: Never.self) {
            try viewModel.addRound(scores: ["10", "4", "12", "17", "33", "1", "12"], game: game, indexOfNegativeNumbers: [])
        }
    }
    
    @Test func addEighthAndNinthPlayers() async throws {
        
        #expect(throws: Never.self) {
            try viewModel.addPlayerToGame(
                name: "Tim",
                game: game,
                useContext: .midGame,
                startScoreMode: .startAtZero
            )
        }
        
        #expect(throws: addPlayerError.tooManyPlayers) {
            try viewModel.addPlayerToGame(
                name: "Jim",
                game: game,
                useContext: .midGame,
                startScoreMode: .startAtZero
            )
        }
    }
}

@Suite("Recalculating scores after an edit")
struct RecalculateScoresTests {

    let viewModel = ViewModel()

    // Scores 30, 20, 25, 25 with halving on: the running total hits 50 after
    // each of the last three rounds, so a halve should be inserted every time.
    @Test func recalculatesRepeatedHalvesWithHalvingOn() async throws {
        let player = SchemaV5.Player(
            name: "Rob",
            scores: [30, 20, 25, 25],
            runningScores: []
        )

        viewModel.recalculateScores(player: player, halving: true)

        // scores array has a negative halve entry inserted after each 50
        #expect(player.scores == [30, 20, -25, 25, -25, 25, -25])
        // running totals carry forward the halved value
        #expect(player.runningScores == [30, 25, 25, 25])
    }

    // With halving off, any previously-inserted negative halve entries should be
    // stripped out of both scores and runningScores.
    @Test func stripsOldHalvesWhenHalvingOff() async throws {
        let player = SchemaV5.Player(
            name: "Rob",
            scores: [30, 20, -25, 25, -25, 25, -25],
            runningScores: []
        )

        viewModel.recalculateScores(player: player, halving: false)

        #expect(player.scores == [30, 20, 25, 25])
        #expect(player.runningScores == [30, 50, 75, 100])
    }
}
