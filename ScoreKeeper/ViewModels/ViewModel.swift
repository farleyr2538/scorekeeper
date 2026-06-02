//
//  ViewModel.swift
//  Yanev
//
//  Created by Robert Farley on 22/06/2025.
//

import Foundation
import SwiftData
import Combine
import SwiftUI


class ViewModel : ObservableObject {
    
    private let allPlayersKey = "allPlayers"
    
    @Published var allPlayers : [String] {
        didSet {
            UserDefaults.standard.set(Array(allPlayers), forKey: allPlayersKey)
        }
    }
    
    @Published var gameNames : [String] {
        didSet {
            UserDefaults.standard.set(Array(gameNames), forKey: "gameNames")
        }
    }
    
    // private let isFirstTimeUsing : Bool
    
    init() {
        
        // load existing game names, if possible
        if let existingGameNames = UserDefaults.standard.stringArray(forKey: "gameNames") {
            self.gameNames = existingGameNames
        } else {
            self.gameNames = []
        }
        
        // load allPlayers
        if let savedNames = UserDefaults.standard.stringArray(forKey: allPlayersKey) {
            self.allPlayers = Set(savedNames).sorted() // Use Set for uniqueness, then sort
        } else {
            self.allPlayers = []
        }
        
    }
    
    func addPlayerName(_ name: String) {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedName.isEmpty {
                allPlayers.append(trimmedName)
            }
    }
    
    // create an empty round with the correct number of players
    func newRound(game: Game) -> [String] {
        let numberOfPlayers = game.players.count
        let newArray = Array(repeating: "", count: numberOfPlayers)
        return newArray
    }
    
    func halve(player: Player) {
        let scoreCount = player.runningScores.count
        let lastScoreIndex = scoreCount - 1
        
        if let mostRecentTotal = player.runningScores.last {
            let newTotal = mostRecentTotal / 2.0
            player.runningScores[lastScoreIndex] = newTotal
        }
    }
    
    
    
    // given a round's scores as a list of strings, validate, then add to a game
    func addRound(scores : [String], game: Game, indexOfNegativeNumbers: [Int]) throws {
        
        print("addRound function started...")
        
        if !checkRoundInput(scoreBuffers: scores) {
            // at least one value is either nil or cannot be converted to Double
            print("reason for failure: at least one value is either nil or cannot be converted to Double")
            throw addRoundError.invalidScore
        } else {
            
            print("adding scores to players' arrays")
            // add scores to each player's scores array
            game.players.indices.forEach { index in
                // this relies on the order of the players matching the order of the scores in scores, so that player[n]'s score is scores[n]
                
                // a copy of this player's score this round
                if let nominalScore = Double(scores[index]) {
                    
                    var realScore : Double
                    
                    if indexOfNegativeNumbers.contains(index) {
                        realScore = 0 - nominalScore
                    } else {
                        realScore = nominalScore
                    }
                    
                    // add score to scores and runningScores, halving if necessary
                    addScore(
                        player: game.players[index],
                        score: realScore,
                        halving: game.halving
                    )
                    
                }
            }
        }
    }
    
    // add a score to both a player's scores and runningScores. half, if necessary.
    func addScore(player: Player, score: Double, halving: Bool) {
        
        // SCORES
        var currentScores = player.scores
        currentScores.append(score)
        let sum = currentScores.reduce(0, +)
            
        if (
            halving // halving is on
            && sum != 0 // current score is not 0
            && sum.truncatingRemainder(dividingBy: 50) == 0 // score is a multiple of 50
            && score != 0 // score this round is not 0
        ) {
            let reductionAmount = sum / 2.0
            let reduction = 0 - reductionAmount
            currentScores.append(reduction)
        }
        
        // re-assign to player's scores
        player.scores = currentScores
        
        
        // RUNNING SCORES
        var newTotal : Double
        var runningScores = player.runningScores
        
        // if there are already values in runningScores, add this rounds score to the existing running total
        if !runningScores.isEmpty {
            let previousTotal = runningScores.last!
            newTotal = previousTotal + score
        } else {
            // otherwise, this round's score is our running total
            newTotal = score
        }

        // test for need to half
        if (
            halving // halving is on
            && newTotal != 0 // new total score is not 0 (although this is impossible if this rounds score is not 0)
            && newTotal.truncatingRemainder(dividingBy: 50) == 0 // new total score is a multiple of 50
            && score != 0 // this rounds score is not 0
        ) {
            newTotal /= 2.0
        }
        
        // add new total to runningScores
        runningScores.append(newTotal)
        
        // re-assign runningScores back to the player's running scores
        player.runningScores = runningScores
        
    }
    
    func getAverageScore(game: Game) -> Double {
        // get the avg of the other players' scores
        var scoresAdded: Double = 0
    
        game.players.forEach { player in
            scoresAdded += player.total
        }
        
        if scoresAdded > 0 {
            let avgScore = scoresAdded / Double(game.players.count)
            return ceil(avgScore)
        } else {
            return 0
        }
    }
    
    func verifyGame(game: Game) throws {
        // if there are no players
        // ... or more than 7
        guard !game.players.isEmpty else {
            throw gameError.noPlayers
        }
        guard !(game.players.count > 8) else {
            throw gameError.tooManyPlayers
        }
    }
    
    func recalculateScores(player: Player, halving: Bool) {
        
        // we been given an updated player, with updated scores, but potentially having incorrect halves (ie. they shouldn't have halved) or missed halves (ie. they should have halved, but haven't).
        // therefore, we need to run through the scores again. if, at any point, the runningScore / 50 == 0 (and neither the round's score or the runningScore is 0) then we need to add a halve at this point.
        
        // assuming that one item in the 'scores' array has been edited, we need to:
            // 1) remove any subtractions/negatives (in case - in light of the new scores - this person should never have halved)
            // 2) go through scores again, halving (ie. adding negatives) where necessary
            // 3) go through runningScores again
                
        // remove all negatives
        let scoresWithoutNegatives = player.scores.filter { $0 >= 0 }
        
        if halving {
            // add negatives back in, in the right places
            var scoresRunningTotal: Double = 0
            var newScoresWithHalving: [Double] = []
            
            for score in scoresWithoutNegatives {
                
                newScoresWithHalving.append(score)
                scoresRunningTotal += score
                
                // check for need to halve
                if (
                    scoresRunningTotal.truncatingRemainder(dividingBy: 50) == 0
                    && scoresRunningTotal > 0
                    && score > 0
                ) {
                    let reductionValue = 0 - (scoresRunningTotal / 2.0)
                    newScoresWithHalving.append(reductionValue)
                }
                
            }
            
            player.scores = newScoresWithHalving
            
        }
        
        // re-calculate runningScores
        player.runningScores.removeAll()
        
        var runningTotal: Double = 0
        
        scoresWithoutNegatives.forEach { score in
            
            // add score to running total
            runningTotal += score
            
            // check conditions for halving
            if (
                halving &&
                runningTotal > 0 &&
                score > 0 &&
                runningTotal.truncatingRemainder(dividingBy: 50) == 0
            ) {
                runningTotal = runningTotal / 2.0
            }
            player.runningScores.append(runningTotal)
        }
    }
    
    // get each player's score for a given round
    func getScores(game: Game, roundIndex: Int) -> [String] {
        var theScores : [String] = []
        
        if let calculatedRoundsPlayed = game.calculatedRoundsPlayed {
            if roundIndex < calculatedRoundsPlayed {
                game.players.forEach { player in
                    let score = player.scores[roundIndex]
                    // Format the double, removing unnecessary decimal places
                    let stringScore: String
                    if score.truncatingRemainder(dividingBy: 1) == 0 {
                        // It's a whole number, show without decimals
                        stringScore = String(Int(score))
                    } else {
                        // It has decimal places
                        stringScore = String(score)
                    }
                    theScores.append(stringScore)
                }
                return theScores
            } else {
                print("getScores() error: roundIndex greater or equal to roundsPlayed")
                return [""]
            }
        } else {
            print("getScores() error: unable to access game.calculatedRoundsPlayed")
            return[""]
        }
    }
    
    // in-game
    // checks for nil values or values not convertible to doubles
    func checkRoundInput(scoreBuffers: [String]) -> Bool {
        var validInput : Bool = true
        scoreBuffers.forEach { scoreBuffer in
            if scoreBuffer.isEmpty || Double(scoreBuffer) == nil {
                validInput = false
            }
        }
        return validInput
    }
    
    // helper
    func generateGameTitle(game: Game) -> String {
        
        let players = game.players
        var playersString = ""
        for (index, _) in players.enumerated() {
            var value = ""
            if index == 0 {
                value = players[index].name
            } else if index == players.count - 1 {
                value = " and \(players[index].name)"
            } else {
                value = ", \(players[index].name)"
            }
            playersString.append(value)
        }
        
        let inputString = " with " + playersString
        return inputString
    }
    
    // helper
    func populateGameNameArray(games: [Game]) {
        
        print("populating game names array...")
        
        var gameNamesArray : [String] = []
        
        for game in games {
            let gameName = game.name ?? ""
            if gameName != "" {
                gameNamesArray.append(gameName)
            }
        }
        
        let uniqueNames = Set(gameNamesArray)
        print("unique names: " + uniqueNames.description)
        self.gameNames = Array(uniqueNames)
        
    }

    // Game Setup
    func prepareGameForCreation(game: Game, gameName: String) throws {
        
        // verify game is valid
        do {
            try verifyGame(game: game)
        } catch let error {
            throw error
        } 
        
        // add player names to player history
        game.players.forEach { player in
            addPlayerName(player.name)
        }
        
        // add game name to gameNames
        let strippedGameName = gameName.trimmingCharacters(in: .whitespaces)
        if strippedGameName != "" && !gameNames.contains(where: { $0 == strippedGameName }) {
            gameNames.append(strippedGameName)
        }
        
        // set game name
        game.name = gameName

    }
    
    // In-Game
    func addPlayerToGame(name: String, game: Game, useContext: Context, startScoreMode: StartScoreMode) throws {
                
        // if there is no name, reject
        if name.isEmpty {
            throw addPlayerError.noName
        }
        
        // if there is already a player with that name, reject - this is not working when it should
        let existingPlayersNames = game.players.map(\.name)
        if existingPlayersNames.contains(name) {
            throw addPlayerError.existingName
        }
        
        if game.players.count + 1 > maxPlayers {
            throw addPlayerError.tooManyPlayers
        }
        
        let newPlayer = Player(
            name: name,
            scores: [],
            runningScores: []
        )
        
        if useContext == .midGame {
            
            let numberOfRounds = game.roundsPlayed
            print("numberOfRounds: " + String(numberOfRounds))
            
            // add zeros for all rounds played so far (except the current one)
            if numberOfRounds > 0 {
                for _ in 0 ..< (numberOfRounds - 1) {
                    addScore(
                        player: newPlayer,
                        score: 0,
                        halving: false
                    )
                }
            }
            
            let firstScore : Double
            
            if startScoreMode == .averageScore {
                firstScore = getAverageScore(game: game)
            } else {
                firstScore = 0
            }
            
            addScore(
                player: newPlayer,
                score: firstScore,
                halving: false
            )
            
            
        }
        
        // add player to game
        game.players.append(newPlayer)
        
    }
    
}

