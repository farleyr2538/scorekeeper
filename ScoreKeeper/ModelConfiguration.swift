//
//  ModelConfiguration.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 16/08/2025.
//

/*

import Foundation
import SwiftData

enum SchemaV1 : VersionedSchema {
    
    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }
    
    static var models: [any PersistentModel.Type] { [Game.self, Player.self] }
    
    @Model
    class Player {
                
        var name : String
        
        @Attribute(.transformable(by: IntArrayTransformer.self)) var scores: [Int] = []
        @Attribute(.transformable(by: IntArrayTransformer.self)) var runningScores: [Int] = []
            
        var total : Int {
            scores.reduce(0, +)
        }
        var average : Double {
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
        
        @Relationship(deleteRule: .cascade)
        var players : [SchemaV1.Player] = []
        
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
}

enum SchemaV2 : VersionedSchema {
    
    static var versionIdentifier: Schema.Version {
            Schema.Version(2, 0, 0)
        }
    
    static var models: [any PersistentModel.Type] { [Game.self, Player.self] }
    
    @Model
    class Player : Identifiable, Hashable {
        
        var id : UUID
        
        var name : String
        
        @Attribute(.transformable(by: IntArrayTransformer.self)) var scores: [Int] = []
        @Attribute(.transformable(by: IntArrayTransformer.self)) var runningScores: [Int] = []
            
        var total : Int {
            scores.reduce(0, +)
        }
        var average : Double {
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
        
        // var uuid = UUID()
        
        @Relationship(deleteRule: .cascade)
        var players : [Player] = []
        
        var date = Date()
        var halving = true
        var lowestWins = true
        var roundsPlayed = 0
        
        init(players: [Player], halving: Bool, lowestWins : Bool = true, date : Date = Date()) {
            self.players = players
            self.halving = halving
            
            self.date = date
            self.lowestWins = lowestWins
        }
    }

}

typealias Player = SchemaV2.Player
typealias Game = SchemaV2.Game

typealias AppSchema = SchemaV2

enum MigrationPlan : SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [
            .custom(fromVersion: SchemaV1.self, toVersion: SchemaV2.self, willMigrate: { context in
                // This closure runs *before* the automatic mapping of the data.
                // We need to manually handle the creation of a new UUID for each Player.
                
                do {
                    // Fetch all existing Player objects from the V1 schema.
                    let oldPlayers = try context.fetch(FetchDescriptor<SchemaV1.Player>())
                    print("Will migrate \(oldPlayers.count) players from V1 to V2.")
                    
                    // For each old player, create a new one with a UUID and insert it.
                    // We do not have to copy other properties, as the automatic mapping
                    // will handle properties that are common to both schemas (like `name`).
                    for oldPlayer in oldPlayers {
                        // Create a new Player object with the V2 schema, assigning a new UUID.
                        let newPlayer = SchemaV2.Player(name: oldPlayer.name, scores: oldPlayer.scores, runningScores: oldPlayer.runningScores)
                        context.insert(newPlayer)
                    }

                    // Important: Delete the old objects to avoid duplicates.
                    // Note: The `context` here is a temporary migration context.
                    for oldPlayer in oldPlayers {
                        context.delete(oldPlayer)
                    }

                } catch {
                    print("Failed to migrate players from V1 to V2: \(error.localizedDescription)")
                }

            }, didMigrate: { context in
                // This closure runs *after* the migration has completed.
                // It's a good place for a final sanity check or cleanup.
                do {
                    let newPlayers = try context.fetch(FetchDescriptor<SchemaV2.Player>())
                    print("Did migrate from \(SchemaV1.versionIdentifier) to \(SchemaV2.versionIdentifier). Total players in new store: \(newPlayers.count).")
                } catch {
                    print("Failed to fetch new players after migration: \(error.localizedDescription)")
                }
            })
        ]
    }
}

/* */



*/
