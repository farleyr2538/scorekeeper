//
//  File.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 16/08/2025.
//

import Foundation
import SwiftData

typealias Player = SchemaV4.Player
typealias Game = SchemaV4.Game

enum SchemaV4: VersionedSchema {
    
    static var versionIdentifier: Schema.Version {
        Schema.Version(4, 0, 0)
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
            Double(total) / Double(scores.count(where: { $0 > 0 }))
        }
        
        var filteredSocres: [Int] {
            scores.filter( { $0 >= 0 } )
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
        
        var name: String?
        var date = Date()
        var halving = true
        var lowestWins = true
        var roundsPlayed = 0
        
        init(players: [Player], name: String? = nil, date: Date = Date(), halving: Bool, lowestWins: Bool = true, roundsPlayed: Int = 0) {
            self.id = UUID()
            self.players = players
            self.name = name
            self.halving = halving
            
            self.date = date
            self.lowestWins = lowestWins
            self.roundsPlayed = roundsPlayed
        }
        
        var winners : [Player] {
            // find the current winner(s) in any given game.
            var winners: [Player] = []
            var winningScore: Int? = nil
            
            if lowestWins { // if lowest score wins
                for player in players { // for each player
                    if winningScore != nil { // if there is an existing winner
                        if player.total == winningScore! { // if this player's score is THE SAME AS the current winning score
                            winners.append(player) // add joint winner
                        } else if player.total < winningScore! { // or if this player's score is LESS THAN the current winning score
                            winners = [player] // then we have a new winnner!
                            winningScore = player.total // update winningScore
                        }
                    } else { // winningScore is nil; therefore player's score is always winning
                        winners = [player]
                        winningScore = player.total
                    }
                }
            } else { // same but for higher scores
                for player in players {
                    if winningScore != nil {
                        if player.total == winningScore! {
                            winners.append(player)
                        } else if player.total > winningScore! {
                            winners = [player]
                            winningScore = player.total
                        }
                    } else { 
                        winners = [player]
                        winningScore = player.total
                    }
                }
            }
            
            return winners
        }
        
        var calculatedRoundsPlayed : Int? {
            
            var collectionOfRounds: [Int] = []
            
            for player in players {
                // count non-negative scores
                var nonNegativeCounter = 0
                for score in player.scores {
                    if score >= 0 {
                        nonNegativeCounter += 1
                    }
                }
                collectionOfRounds.append(nonNegativeCounter)
                
            }
            // if they are not all the same, defer to roundsPlayed
            let setVersion = Set(collectionOfRounds)
            if setVersion.count == 1 {
                return collectionOfRounds.first
            } else {
                return nil
            }
        }
        
    }
    
}

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
            Double(total) / Double(scores.count(where: { $0 > 0 }))
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

enum ScoreKeeperMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV2.self, SchemaV3.self, SchemaV4.self]
    }
    
    static var stages: [MigrationStage] {
        [
            migrateV2ToV3,
            migrateV3ToV4
        ]
    }
    
    static let migrateV2ToV3 = MigrationStage.lightweight(
        fromVersion: SchemaV2.self,
        toVersion: SchemaV3.self
    )
    
    static let migrateV3ToV4 = MigrationStage.lightweight(
        fromVersion: SchemaV3.self,
        toVersion: SchemaV4.self
    )
}

extension SchemaV4.Game {
    static var sampleGames : [Game] {
        [
            Game(
                players: [
                    Player(
                        name: "Rob",
                        scores: [29, 0, 14, 0, 15, 21, 2, 10, 0, 0, 5, 10, 35, 15, 0, 0, 0],
                        runningScores: [29, 29, 43, 43, 58, 79, 81, 91, 91, 91, 96, 106, 141, 156, 156, 156, 156]
                    ),
                    Player(
                        name: "Flora",
                        scores: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14],
                        runningScores: [36, 49, 65, 78, 102, 123, 129, 129, 159, 195, 208, 257, 260, 299, 306, 351, 365]
                    ),
                    Player(
                        name: "Vnesh",
                        scores: [0, 3, 0, 7, 0, 0, 0, 26, 9, 12, 0, 0, 11, 0, 7, 6, 19],
                        runningScores: [0, 3, 3, 10, 10, 10, 10, 36, 45, 57, 57, 57, 68, 68, 75, 81, 100]
                    )
                ],
                name: "Yaniv",
                halving: true,
                roundsPlayed: 17
            ),
            Game(
                players: [
                    Player(
                        name: "Rob",
                        scores: [29, 0, 14, 0, 15, 21, 2, 10, 0, 0, 5, 10, 35, 15, 0, 0, 0],
                        runningScores: [29, 29, 43, 43, 58, 79, 81, 91, 91, 91, 96, 106, 141, 156, 156, 156, 156]
                    ),
                    Player(
                        name: "Flora",
                        scores: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14],
                        runningScores: [36, 49, 65, 78, 102, 123, 129, 129, 159, 195, 208, 257, 260, 299, 306, 351, 365]
                    ),
                    Player(
                        name: "Vnesh",
                        scores: [0, 3, 0, 7, 0, 0, 0, 26, 9, 12, 0, 0, 11, 0, 7, 6, 19],
                        runningScores: [0, 3, 3, 10, 10, 10, 10, 36, 45, 57, 57, 57, 68, 68, 75, 81, 100]
                    )
                ],
                halving: true,
                roundsPlayed: 17
            ),
            Game(players: [
                    Player(
                        name: "Rob",
                        scores: [29, 0, 14, 0, 15, 21, 2, 10, 0, 0, 5, 10, 35, 15, 0, 0, 0],
                        runningScores: [29, 29, 43, 43, 58, 79, 81, 91, 91, 91, 96, 106, 141, 156, 156, 156, 156]
                    ),
                    Player(
                        name: "Flora",
                        scores: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14],
                        runningScores: [36, 49, 65, 78, 102, 123, 129, 129, 159, 195, 208, 257, 260, 299, 306, 351, 365]
                    ),
                    Player(
                        name: "Vnesh",
                        scores: [0, 3, 0, 7, 0, 0, 0, 26, 9, 12, 0, 0, 11, 0, 7, 6, 19],
                        runningScores: [0, 3, 3, 10, 10, 10, 10, 36, 45, 57, 57, 57, 68, 68, 75, 81, 100]
                    )
                ],
                 name: "Dixit",
                halving: true,
                roundsPlayed: 17
            )
        ]
    }
}
