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
        [SchemaV2.self, SchemaV3.self, SchemaV5.self]
    }

    static var stages: [MigrationStage] {
        [
            migrateV2ToV3,
            migrateV3ToV5
        ]
    }

    // A no-op custom stage, not lightweight: when every stage is lightweight,
    // Core Data skips the intermediate versions and attempts a direct V2->V5
    // migration, which fails to infer a mapping. A custom stage forces the
    // migration to actually pass through V3.
    static let migrateV2ToV3 = MigrationStage.custom(
        fromVersion: SchemaV2.self,
        toVersion: SchemaV3.self,
        willMigrate: nil,
        didMigrate: nil
    )

    // V4's only difference from V5 was scores/runningScores being [Int] instead
    // of [Double]. Both are stored as identical encoded blobs, so V4 and V5
    // produce the same model checksum: SwiftData opens V4 stores directly as V5
    // (stored integers decode fine into Double), and a custom V4->V5 stage
    // throws NSException at launch because its from/to models are not distinct.
    // So the plan must skip V4 entirely and migrate V3 straight to V5.
    static let migrateV3ToV5 = MigrationStage.lightweight(
        fromVersion: SchemaV3.self,
        toVersion: SchemaV5.self
    )
}
