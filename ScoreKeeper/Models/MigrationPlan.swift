//
//  MigrationPlan.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 02/06/2026.
//

import Foundation
import SwiftData

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
