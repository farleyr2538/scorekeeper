//
//  ViewModel.swift
//  Yanev
//
//  Created by Robert Farley on 22/06/2025.
//

import Foundation
import SwiftData
import Combine


enum gameError : Error {
    case tooManyPlayers
    case noPlayers
}

class ViewModel : ObservableObject {
    
    private let userDefaultsKey = "allPlayers"
    
    @Published var allPlayers : [String] {
        didSet {
            UserDefaults.standard.set(Array(allPlayers), forKey: userDefaultsKey)
            print("allPlayers saved to User Defaults")
        }
    }
    
    init() {
        // Load allKnownPlayerNames from UserDefaults when the ViewModel is initialized
        if let savedNames = UserDefaults.standard.stringArray(forKey: userDefaultsKey) {
            self.allPlayers = Set(savedNames).sorted() // Use Set for uniqueness, then sort
            print("allKnownPlayerNames loaded from UserDefaults: \(self.allPlayers.count) names") // For debugging
        } else {
            self.allPlayers = []
            print("No allKnownPlayerNames found in UserDefaults. Initializing empty.") // For debugging
        }
    }
    
    func addPlayerName(_ name: String) {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedName.isEmpty && !allPlayers.contains(trimmedName) {
                allPlayers.append(trimmedName)
                allPlayers.sort() // Keep the list sorted alphabetically
                print("Added '\(trimmedName)' to allKnownPlayerNames. Current count: \(allPlayers.count)") // For debugging
            } else if trimmedName.isEmpty {
                print("Attempted to add empty name to allKnownPlayerNames. Ignored.")
            } else {
                print("'\(trimmedName)' already exists in allKnownPlayerNames. No action needed.")
            }
        }
    
    func newRound(game: Game) -> [String] {
        let length = game.players.count
        let newArray = Array(repeating: "", count: length)
        return newArray
    }
    
    func halve(player: Player) {
        let scoreCount = player.runningScores.count
        let lastScoreIndex = scoreCount - 1
        
        if let mostRecentTotal = player.runningScores.last {
            let newTotal = mostRecentTotal / 2
            player.runningScores[lastScoreIndex] = newTotal
        }
    }
    
    // add a score to both a player's scores and runningScores. half, if necessary.
    func addScore(player: Player, score: Int, halving: Bool) {
        
        // SCORES
        var currentScores = player.scores
        currentScores.append(score)
            
        if (halving && currentScores.reduce(0, +) != 0 && currentScores.reduce(0, +) % 50 == 0 && score != 0) {
            let reductionAmount = currentScores.reduce(0, +) / 2
            let reduction = 0 - reductionAmount
            currentScores.append(reduction)
        }
        
        // re-assign to player's scores
        player.scores = currentScores
        
        // RUNNING SCORES
        var newScore : Int
        
        // if there are already values in runningScores, add this rounds score to the existing running total
        if !player.runningScores.isEmpty {
            let runningScore = player.runningScores.last!
            newScore = runningScore + score
        } else {
            // otherwise, this rounds score is our running total
            newScore = score
        }
        
        // test for need to half
        if (halving && newScore % 50 == 0 && score != 0 && newScore != 0) {
            newScore /= 2
        }
        
        // add new score
        var currentRunningScores = player.runningScores
        currentRunningScores.append(newScore)
        player.runningScores = currentRunningScores
        
    }
    
    func getAverageScore(game: Game) -> Int {
        // get the avg of the other players' scores
        var scoresAdded = 0
    
        game.players.forEach { player in
            scoresAdded += player.total
        }
        
        if scoresAdded > 0 {
            let avgScoreDouble : Double = Double(scoresAdded) / Double(game.players.count)
            let avgScore = Int(ceil(avgScoreDouble))
            return avgScore
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
        guard !(game.players.count > 7) else {
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
        
        if halving {
            // remove all negatives
            let scoresWithoutNegatives = player.scores.filter { $0 >= 0 }
            
            // add negatives back in, in the right places
            var scoresRunningTotal = 0
            var newScoresWithHalving: [Int] = []
            
            for score in scoresWithoutNegatives {
                newScoresWithHalving.append(score)
                scoresRunningTotal += score
                
                if (scoresRunningTotal % 50 == 0) && (scoresRunningTotal > 0) && (score > 0) {
                    let reductionValue = 0 - (scoresRunningTotal / 2)
                    newScoresWithHalving.append(reductionValue)
                }
                
            }
            
            player.scores = newScoresWithHalving
            
        }
        
        let adjustedScores = player.scores
        
        // re-calculate runningScores
        player.runningScores.removeAll()
        var runningTotal = 0
        adjustedScores.forEach { score in
            runningTotal = runningTotal + score
            if halving && runningTotal % 50 == 0 && runningTotal > 0 && score > 0 {
                runningTotal = runningTotal / 2
            }
            player.runningScores.append(runningTotal)
        }
    }
    
    // get each player's score for a given round
    func getScores(game: Game, roundIndex: Int) -> [String] {
        var theScores : [String] = []
        game.players.forEach { player in
            let score = player.scores[roundIndex]
            let stringScore = String(score)
            theScores.append(stringScore)
        }
        return theScores
    }
    
    // validate round input
    func checkRoundInput(scoreBuffers: [String]) -> Bool {
        var validInput : Bool = true
        scoreBuffers.forEach { scoreBuffer in
            if scoreBuffer.isEmpty || Int(scoreBuffer) == nil {
                validInput = false
            }
        }
        return validInput
    }
    
    func generateGameTitle(game: Game) -> String {
        let dateString = game.date.formatted(date: .abbreviated, time: .shortened)
        
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
        
        let inputString = dateString + " with " + playersString
        return inputString
    }
    
}

