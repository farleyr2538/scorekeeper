//
//  File.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 16/08/2025.
//

import Foundation
import SwiftData

enum SchemaV3: VersionedSchema {
    
    static var versionIdentifier: Schema.Version {
        Schema.Version(3, 0, 0)
    }
    
    static var models: [any PersistentModel.Type] { [Game.self, Player.self] }
    
    @Model
    class Player: Identifiable, Hashable {
        
        var id: UUID
        
        var name: String
        
        var scores: [Int] = []
        var runningScores: [Int] = []
           
        var total: Int {
            scores.reduce(0, +)
        }
        var average: Double {
            Double(total) / Double(scores.count)
        }
        
        init(name: String, scores: [Int], runningScores: [Int]) {
            self.id = UUID()
            self.name = name
            self.scores = scores
            self.runningScores = runningScores
        }
        
        static func == (lhs: Player, rhs: Player) -> Bool {
            lhs.id == rhs.id
        }

        // Hash into the hasher using the unique identifier.
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    @Model
    class Game {
        
        var id : UUID
        
        @Relationship(deleteRule: .cascade)
        var players: [Player] = []
        
        var date = Date()
        var halving = true
        var lowestWins = true
        var roundsPlayed = 0
        
        init(players: [Player], halving: Bool, lowestWins: Bool = true, date: Date = Date()) {
            self.id = UUID()
            self.players = players
            self.halving = halving
            
            self.date = date
            self.lowestWins = lowestWins
        }
    }
    
}

enum SchemaV2: VersionedSchema {
    
    static var versionIdentifier: Schema.Version {
        Schema.Version(2, 0, 0)
    }
    
    static var models: [any PersistentModel.Type] { [Game.self, Player.self] }
    
    @Model
    class Player: Identifiable, Hashable {
        
        var id: UUID
        
        var name: String
        
        var scores: [Int] = []
        var runningScores: [Int] = []
           
        var total: Int {
            scores.reduce(0, +)
        }
        var average: Double {
            Double(total) / Double(scores.count)
        }
        
        init(name: String, scores: [Int], runningScores: [Int]) {
            self.id = UUID()
            self.name = name
            self.scores = scores
            self.runningScores = runningScores
        }
        
        static func == (lhs: Player, rhs: Player) -> Bool {
            lhs.id == rhs.id
        }

        // Hash into the hasher using the unique identifier.
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    @Model
    class Game {
        
        // var id = UUID()
        
        @Relationship(deleteRule: .cascade)
        var players: [Player] = []
        
        var date = Date()
        var halving = true
        var lowestWins = true
        var roundsPlayed = 0
        
        init(players: [Player], halving: Bool, lowestWins: Bool = true, date: Date = Date()) {
            self.players = players
            self.halving = halving
            
            self.date = date
            self.lowestWins = lowestWins
        }
    }
    
}

/*
enum SchemaV1: VersionedSchema {
    
    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }
    
    static var models: [any PersistentModel.Type] { [Game.self, Player.self] }
    
    @Model
    class Player {
        
        // var id: UUID
        
        var name: String
        
        var scores: [Int] = []
        var runningScores: [Int] = []
           
        var total: Int {
            scores.reduce(0, +)
        }
        var average: Double {
            Double(total) / Double(scores.count)
        }
        
        init(name: String, scores: [Int], runningScores: [Int]) {
            self.name = name
            self.scores = scores
            self.runningScores = runningScores
        }
    }

    @Model
    class Game {
        
        // var uuid = UUID()
        
        var players: [Player] = []
        
        var date = Date()
        var halving = true
        var lowestWins = true
        var roundsPlayed = 0
        
        init(players: [Player], halving: Bool, lowestWins: Bool = true, date: Date = Date()) {
            self.players = players
            self.halving = halving
            
            self.date = date
            self.lowestWins = lowestWins
        }
    }
    
}
 */

typealias Player = SchemaV3.Player
typealias Game = SchemaV3.Game
