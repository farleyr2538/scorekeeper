//
//  ScoreKeeperTests.swift
//  ScoreKeeperTests
//
//  Created by Rob Farley on 30/05/2026.
//

import Testing
import Observation
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

@Suite("Progress chart keeps up with new rounds")
@MainActor
struct ScoreChartTests {

    let viewModel = ViewModel()

    // The game from the bug report: four players, six rounds, halving on. The
    // chart froze after round 2 and never showed rounds 3 to 6.
    let playerNames = ["Flora", "Vnesh", "Kate", "Rob"]
    let rounds: [[String]] = [
        ["21", "0", "21", "14"],
        ["8", "14", "0", "21"],
        ["18", "6", "0", "3"],
        ["17", "0", "13", "21"],
        ["4", "31", "2", "1"],
        ["4", "32", "2", "11"]
    ]

    func makeGame() -> Game {
        let players = playerNames.map { Player(name: $0, scores: [], runningScores: []) }
        return Game(players: players, halving: true)
    }

    // add a round the same way NewRoundSheet does
    func addRound(_ scores: [String], to game: Game) throws {
        try viewModel.addRound(scores: scores, game: game, indexOfNegativeNumbers: [])
        game.roundsPlayed += 1
    }

    // the chart's running totals for one player, from round 0 onwards
    func plottedScores(for name: String, in chart: ScoreChart) -> [Double] {
        chart.chartPoints
            .filter { $0.playerName == name }
            .sorted { $0.round < $1.round }
            .map(\.score)
    }

    @Test func chartPlotsEveryRoundOfTheReportedGame() throws {
        let game = makeGame()
        let chart = ScoreChart(game: game)

        for (index, round) in rounds.enumerated() {
            try addRound(round, to: game)

            // round 0 plus every round played so far, for every player
            for name in playerNames {
                #expect(plottedScores(for: name, in: chart).count == index + 2)
            }
        }

        #expect(plottedScores(for: "Flora", in: chart) == [0, 21, 29, 47, 64, 68, 72])
        #expect(plottedScores(for: "Vnesh", in: chart) == [0, 0, 14, 20, 20, 51, 83])
        #expect(plottedScores(for: "Kate", in: chart) == [0, 21, 21, 21, 34, 36, 38])
        #expect(plottedScores(for: "Rob", in: chart) == [0, 14, 35, 38, 59, 60, 71])
    }

    // The root cause: the chart read runningScores somewhere SwiftUI couldn't
    // see, so adding a round never told it to redraw. Reading chartPoints must
    // register a dependency that fires when the next round goes in.
    @Test func addingARoundAfterRoundTwoInvalidatesTheChart() throws {
        let game = makeGame()
        let chart = ScoreChart(game: game)

        try addRound(rounds[0], to: game)
        try addRound(rounds[1], to: game)

        // onChange is a Sendable closure, so it flips a flag on a reference type
        final class Flag: @unchecked Sendable { var isSet = false }
        let chartInvalidated = Flag()

        withObservationTracking {
            _ = chart.chartPoints
        } onChange: {
            chartInvalidated.isSet = true
        }

        try addRound(rounds[2], to: game)

        #expect(chartInvalidated.isSet)
        #expect(plottedScores(for: "Flora", in: chart) == [0, 21, 29, 47])
    }
}
