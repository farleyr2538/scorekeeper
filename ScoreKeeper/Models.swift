//
//  File.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 16/08/2025.
//

import Foundation
import SwiftData

typealias Player = SchemaV5.Player
typealias Game = SchemaV5.Game

enum SchemaV5: VersionedSchema {
    
    static var versionIdentifier: Schema.Version {
        Schema.Version(5, 0, 0)
    }
    
    static var models: [any PersistentModel.Type] { [Game.self, Player.self] }
    
    @Model
    class Player: Identifiable, Hashable {
        
        var id: UUID
        
        var name: String
        
        var scores: [Double] = []
        var runningScores: [Double] = []
           
        var total: Double {
            scores.reduce(0, +)
        }
        var average: Double {
            total / Double(scores.count(where: { $0 > 0 }))
        }
        
        var filteredScores: [Double] {
            scores.filter( { $0 >= 0 } )
        }
        
        init(name: String, scores: [Double], runningScores: [Double]) {
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
            var winningScore: Double? = nil
            
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
        
        var filteredScores: [Int] {
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
        [SchemaV2.self, SchemaV3.self, SchemaV4.self, SchemaV5.self]
    }
    
    static var stages: [MigrationStage] {
        [
            migrateV2ToV3,
            migrateV3ToV4,
            migrateV4ToV5
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
    
    static let migrateV4ToV5 = MigrationStage.custom(
        fromVersion: SchemaV4.self,
        toVersion: SchemaV5.self,
        willMigrate: nil,
        didMigrate: { context in
            // Fetch all V4 players from the context
            let playerFetchDescriptor = FetchDescriptor<SchemaV4.Player>()
            let oldPlayers = try context.fetch(playerFetchDescriptor)
            
            // For each V4 player, create a new V5 player with converted scores
            for oldPlayer in oldPlayers {
                let newScores = oldPlayer.scores.map { Double($0) }
                let newRunningScores = oldPlayer.runningScores.map { Double($0) }
                
                let newPlayer = SchemaV5.Player(
                    name: oldPlayer.name,
                    scores: newScores,
                    runningScores: newRunningScores
                )
                newPlayer.id = oldPlayer.id
                
                context.insert(newPlayer)
            }
            
            // Fetch all V4 games and recreate them with V5 players
            let gameFetchDescriptor = FetchDescriptor<SchemaV4.Game>()
            let oldGames = try context.fetch(gameFetchDescriptor)
            
            for oldGame in oldGames {
                // Map old player IDs to new players
                let newPlayers = oldGame.players.compactMap { oldPlayer -> SchemaV5.Player? in
                    let playerId = oldPlayer.id
                    let descriptor = FetchDescriptor<SchemaV5.Player>(
                        predicate: #Predicate { $0.id == playerId }
                    )
                    return try? context.fetch(descriptor).first
                }
                
                let newGame = SchemaV5.Game(
                    players: newPlayers,
                    name: oldGame.name,
                    date: oldGame.date,
                    halving: oldGame.halving,
                    lowestWins: oldGame.lowestWins,
                    roundsPlayed: oldGame.roundsPlayed
                )
                newGame.id = oldGame.id
                
                context.insert(newGame)
            }
            
            // Save new data first - if this fails, the migration will throw
            // and old data will remain intact
            try context.save()
            
            // Only delete old data after successful save
            for oldPlayer in oldPlayers {
                context.delete(oldPlayer)
            }
            for oldGame in oldGames {
                context.delete(oldGame)
            }
            
            // Final save to commit deletions
            try context.save()
        }
    )
}

extension Game {
    static var sampleGames : [Game] {
        [
            Game(
                players: [
                    Player(
                        name: "Rob",
                        scores: [29.0, 0.0, 14.0, 0.0, 15.0, 21.0, 2.0, 10.0, 0.0, 0.0, 5.0, 10.0, 35.0, 15.0, 0.0, 0.0, 0.0],
                        runningScores: [29.0, 29.0, 43.0, 43.0, 58.0, 79.0, 81.0, 91.0, 91.0, 91.0, 96.0, 106.0, 141.0, 156.0, 156.0, 156.0, 156.0]
                    ),
                    Player(
                        name: "Flora",
                        scores: [36.0, 13.0, 16.0, 13.0, 24.0, 21.0, 6.0, 0.0, 30.0, 36.0, 13.0, 49.0, 3.0, 39.0, 7.0, 45.0, 14.0],
                        runningScores: [36.0, 49.0, 65.0, 78.0, 102.0, 123.0, 129.0, 129.0, 159.0, 195.0, 208.0, 257.0, 260.0, 299.0, 306.0, 351.0, 365.0]
                    ),
                    Player(
                        name: "Vnesh",
                        scores: [0.0, 3.0, 0.0, 7.0, 0.0, 0.0, 0.0, 26.0, 9.0, 12.0, 0.0, 0.0, 11.0, 0.0, 7.0, 6.0, 19.0],
                        runningScores: [0.0, 3.0, 3.0, 10.0, 10.0, 10.0, 10.0, 36.0, 45.0, 57.0, 57.0, 57.0, 68.0, 68.0, 75.0, 81.0, 100.0]
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
                        scores: [29.0, 0.0, 14.0, 0.0, 15.0, 21.0, 2.0, 10.0, 0.0, 0.0, 5.0, 10.0, 35.0, 15.0, 0.0, 0.0, 0.0],
                        runningScores: [29.0, 29.0, 43.0, 43.0, 58.0, 79.0, 81.0, 91.0, 91.0, 91.0, 96.0, 106.0, 141.0, 156.0, 156.0, 156.0, 156.0]
                    ),
                    Player(
                        name: "Flora",
                        scores: [36.0, 13.0, 16.0, 13.0, 24.0, 21.0, 6.0, 0.0, 30.0, 36.0, 13.0, 49.0, 3.0, 39.0, 7.0, 45.0, 14.0],
                        runningScores: [36.0, 49.0, 65.0, 78.0, 102.0, 123.0, 129.0, 129.0, 159.0, 195.0, 208.0, 257.0, 260.0, 299.0, 306.0, 351.0, 365.0]
                    ),
                    Player(
                        name: "Vnesh",
                        scores: [0.0, 3.0, 0.0, 7.0, 0.0, 0.0, 0.0, 26.0, 9.0, 12.0, 0.0, 0.0, 11.0, 0.0, 7.0, 6.0, 19.0],
                        runningScores: [0.0, 3.0, 3.0, 10.0, 10.0, 10.0, 10.0, 36.0, 45.0, 57.0, 57.0, 57.0, 68.0, 68.0, 75.0, 81.0, 100.0]
                    )
                ],
                halving: true,
                roundsPlayed: 17
            ),
            Game(players: [
                    Player(
                        name: "Rob",
                        scores: [29.0, 0.0, 14.0, 0.0, 15.0, 21.0, 2.0, 10.0, 0.0, 0.0, 5.0, 10.0, 35.0, 15.0, 0.0, 0.0, 0.0],
                        runningScores: [29.0, 29.0, 43.0, 43.0, 58.0, 79.0, 81.0, 91.0, 91.0, 91.0, 96.0, 106.0, 141.0, 156.0, 156.0, 156.0, 156.0]
                    ),
                    Player(
                        name: "Flora",
                        scores: [36.0, 13.0, 16.0, 13.0, 24.0, 21.0, 6.0, 0.0, 30.0, 36.0, 13.0, 49.0, 3.0, 39.0, 7.0, 45.0, 14.0],
                        runningScores: [36.0, 49.0, 65.0, 78.0, 102.0, 123.0, 129.0, 129.0, 159.0, 195.0, 208.0, 257.0, 260.0, 299.0, 306.0, 351.0, 365.0]
                    ),
                    Player(
                        name: "Vnesh",
                        scores: [0.0, 3.0, 0.0, 7.0, 0.0, 0.0, 0.0, 26.0, 9.0, 12.0, 0.0, 0.0, 11.0, 0.0, 7.0, 6.0, 19.0],
                        runningScores: [0.0, 3.0, 3.0, 10.0, 10.0, 10.0, 10.0, 36.0, 45.0, 57.0, 57.0, 57.0, 68.0, 68.0, 75.0, 81.0, 100.0]
                    )
                ],
                 name: "Dixit",
                halving: true,
                roundsPlayed: 17
            )
        ]
    }
}
