//
//  YanevApp.swift
//  Yanev
//
//  Created by Robert Farley on 22/06/2025.
//

import SwiftUI
import SwiftData

@main
struct ScoreKeeperApp: App {
    
    let sharedModelContainer : ModelContainer
    
    init() {
                    
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            sharedModelContainer = try ModelContainer(
                for: Game.self, Player.self,
                migrationPlan: ScoreKeeperMigrationPlan.self,
                configurations: config
            )
            sharedModelContainer.mainContext.autosaveEnabled = true
        } catch {
            // schema mismatch or load error: delete old store and retry
            print("Schema mismatch detected. Deleting old store due to incompatibility: \(error)")
            
            // get the default store URL (assuming default configuration; customize if you use a named store)
            let defaultConfig = ModelConfiguration()
            let storeURL = defaultConfig.url
            
            let fileManager = FileManager.default
            // delete main store and support files ( WAL and SHM for SQLite)
            try? fileManager.removeItem(at: storeURL)
            try? fileManager.removeItem(at: storeURL.appendingPathExtension("shm"))
            try? fileManager.removeItem(at: storeURL.appendingPathExtension("wal"))
            
            // retry creation (should succeed with fresh store)
            do {
                sharedModelContainer = try ModelContainer(
                    for: Game.self, Player.self,
                    migrationPlan: ScoreKeeperMigrationPlan.self
                )
            } catch {
                fatalError("Failed to delete and recreate ModelContainer: \(error)")
            }
        }
    }
    
    @StateObject var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
