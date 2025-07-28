//
//  ViewModel.swift
//  Yanev
//
//  Created by Robert Farley on 22/06/2025.
//

import Foundation
import SwiftData

@Model
class Player {
    
    // var uuid = UUID()
    
    var name : String
    var scores : intArray
    var runningScores : intArray 
    var total : Int {
        scores.values.reduce(0, +)
    }
    var average : Double {
        Double(total) / Double(scores.values.count)
    }
    
    init(name: String, scores: intArray, runningScores: intArray) {
        self.name = name
        self.scores = scores
        self.runningScores = runningScores
    }
}

@Model
class Game {
    
    // var uuid = UUID()
    
    var players : [Player]
    
    var date = Date()
    var halving = true
    var lowestWins = true
    
    init(players: [Player], halving: Bool, lowestWins : Bool = true, date : Date = Date()) {
        self.players = players
        self.halving = halving
        
        self.date = date
        self.lowestWins = lowestWins
    }
}

struct intArray : Codable {
    var values: [Int]
}

enum gameError : Error {
    case tooManyPlayers
    case noPlayers
}

class ViewModel : ObservableObject {
    
    var allPlayers : [String] = []
    
    func newRound(game: Game) -> [String] {
        let length = game.players.count
        let newArray = Array(repeating: "", count: length)
        return newArray
    }
    
    func halve(player: Player) {
        let scoreCount = player.runningScores.values.count
        let lastScoreIndex = scoreCount - 1
        
        if let mostRecentTotal = player.runningScores.values.last {
            let newTotal = mostRecentTotal / 2
            player.runningScores.values[lastScoreIndex] = newTotal
        }
    }
    
    // add a score to both a player's scores and runningScores. half, if necessary.
    func addScore(player: Player, score: Int, halving: Bool) {
        
        // scores
        
        player.scores.values.append(score)
            
        if (halving && player.total != 0 && player.total % 50 == 0 && score != 0) {
            let reductionAmount = player.total / 2
            let reduction = 0 - reductionAmount
            player.scores.values.append(reduction)
        }
        
        // runningScores
    
        var newScore : Int
        
        // if there are already values in runningScores, add this rounds score to the existing running total
        if !player.runningScores.values.isEmpty {
            let runningScore = player.runningScores.values.last!
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
        player.runningScores.values.append(newScore)
        
    }
    
    func getAverageScore(game: Game) -> Int {
        // get the avg of the other players' scores
        var scoresAdded = 0
    
        game.players.forEach { player in
            scoresAdded += player.total
        }
        let avgScoreDouble : Double = Double(scoresAdded) / Double(game.players.count)
        let avgScore = Int(ceil(avgScoreDouble))
        return avgScore
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
        
        // what do we need to do?
        // we been given an updated player, with updated scores, but potentially having incorrect halves (ie. they shouldn't have halved) or missed halves (ie. they should have halved, but haven't).
        // therefore, we need to run through the scores again. if, at any point, the runningScore / 50 == 0 (and neither the round's score or the runningScore is 0) then we need to add a halve at this point.
        
        // assuming that one item in the 'scores' array has been edited, we need to:
            // 1) remove any subtractions/negatives (in case - in light of the new scores - this person should never have halved)
            // 2) go through scores again, halving (ie. adding negatives) where necessary
            // 3) go through runningScores again
        
        
        if halving {
            // remove all negatives
            player.scores.values.removeAll { $0 < 0 }
            
            // add negatives back in, in the right places - THIS IS NOT WORKING CURRENTLY
            var runningTotal = 0
            player.scores.values.enumerated().forEach { index, score in
                runningTotal += score
                if (runningTotal % 50 == 0) && (runningTotal > 0) && (score > 0) {
                    let reductionValue = 0 - (runningTotal / 2)

                    // half
                    player.scores.values.insert(reductionValue, at: index + 1)
                }
            }
        }
        
        // re-calculate runningScores
        player.runningScores.values.removeAll()
        var runningTotal = 0
        player.scores.values.forEach { score in
            runningTotal = runningTotal + score
            if halving && runningTotal % 50 == 0 && runningTotal > 0 && score > 0 {
                runningTotal = runningTotal / 2
            }
            player.runningScores.values.append(runningTotal)
        }

    }
    
    // get each player's score for a given round
    func getScores(game: Game, roundIndex: Int) -> [String] {
        var theScores : [String] = []
        game.players.forEach { player in
            let score = player.scores.values[roundIndex]
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
