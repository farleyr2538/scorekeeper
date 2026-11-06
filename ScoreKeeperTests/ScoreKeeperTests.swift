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
        
        var players : [Player] = []
        names.forEach { name in
            let player = Player(name: name, scores: [], runningScores: [])
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
        let player = Player(
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
        let player = Player(
            name: "Rob",
            scores: [30, 20, -25, 25, -25, 25, -25],
            runningScores: []
        )

        viewModel.recalculateScores(player: player, halving: false)

        #expect(player.scores == [30, 20, 25, 25])
        #expect(player.runningScores == [30, 50, 75, 100])
    }
}

@Suite("Averaged-in starting scores")
struct AveragedInStartingScoreTests {

    let viewModel = ViewModel()

    // A player averaged in on a multiple of 50 keeps that score: the recorded
    // starting round is exempt from halving, both now and on any later recalc.
    @Test func averagedInStartingScoreDoesNotHalve() async throws {
        let player = Player(
            name: "Tim",
            scores: [0, 0, 150, 25],
            runningScores: [],
            startingScoreRoundIndex: 2
        )

        viewModel.recalculateScores(player: player, halving: true)

        // no halve inserted for the 150, and 175 is not a multiple of 50
        #expect(player.scores == [0, 0, 150, 25])
        #expect(player.runningScores == [0, 0, 150, 175])
    }

    // The same scores without a recorded starting round: the 150 is treated as
    // an ordinary round, so it halves - and the halved total then hits 100.
    @Test func ordinaryScoreOnMultipleOfFiftyStillHalves() async throws {
        let player = Player(
            name: "Tim",
            scores: [0, 0, 150, 25],
            runningScores: []
        )

        viewModel.recalculateScores(player: player, halving: true)

        #expect(player.scores == [0, 0, 150, -75, 25, -50])
        #expect(player.runningScores == [0, 0, 75, 50])
    }

    // A player averaged in mid-game has the joining round recorded, so the
    // starting score can be exempted from halving later on.
    @Test func joiningMidGameRecordsTheStartingRound() async throws {
        let existingPlayer = Player(
            name: "Rob",
            scores: [40, 60, 50],
            runningScores: [40, 100, 150]
        )
        let game = Game(players: [existingPlayer], halving: true, roundsPlayed: 3)

        try viewModel.addPlayerToGame(
            name: "Tim",
            game: game,
            useContext: .midGame,
            startScoreMode: .averageScore
        )

        let newPlayer = try #require(game.players.last)

        // two zeros for the completed rounds, then the averaged-in score
        #expect(newPlayer.startingScoreRoundIndex == 2)
        #expect(newPlayer.scores == [0, 0, 150])
        #expect(newPlayer.runningScores == [0, 0, 150])
    }

    // Deleting rounds shifts the remaining ones, so the recorded starting round
    // has to move with them.
    @Test func deletingAnEarlierRoundShiftsTheStartingRound() async throws {
        let player = Player(
            name: "Tim",
            scores: [0, 0, 150],
            runningScores: [],
            startingScoreRoundIndex: 2
        )
        let game = Game(players: [player], halving: true)

        viewModel.adjustStartingScoreIndexes(game: game, deletedRoundIndexes: [0])

        #expect(player.startingScoreRoundIndex == 1)
    }

    // Deleting the joining round itself clears the record entirely.
    @Test func deletingTheStartingRoundClearsIt() async throws {
        let player = Player(
            name: "Tim",
            scores: [0, 0, 150],
            runningScores: [],
            startingScoreRoundIndex: 2
        )
        let game = Game(players: [player], halving: true)

        viewModel.adjustStartingScoreIndexes(game: game, deletedRoundIndexes: [2])

        #expect(player.startingScoreRoundIndex == nil)
    }
}
