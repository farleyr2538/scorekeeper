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
