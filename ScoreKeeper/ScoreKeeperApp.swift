//
//  YanevApp.swift
//  Yanev
//
//  Created by Robert Farley on 22/06/2025.
//

import SwiftUI
import SwiftData
import CloudKit

@main
struct ScoreKeeperApp: App {
    
    let sharedModelContainer : ModelContainer
    let containerLoadFailed : Bool
    
    init() {
        
        /*
         let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
         */
                    
        do {
            
            let config = ModelConfiguration(
                isStoredInMemoryOnly: false,
                // cloudKitDatabase: isPreview ? .none : .automatic
            )
            
            sharedModelContainer = try ModelContainer(
                for: Game.self, Player.self,
                migrationPlan: ScoreKeeperMigrationPlan.self,
                configurations: config
            )
            
            sharedModelContainer.mainContext.autosaveEnabled = true
            
            containerLoadFailed = false
            
        } catch {
            
            print("ModelContainer failed to load: \(error)")
            
            sharedModelContainer = try! ModelContainer(
                for: Game.self, Player.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            
            containerLoadFailed = true
            
        }
    }
    
    @StateObject var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            if containerLoadFailed {
                ContentUnavailableView(
                    "Data Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text("There was a problem loading your data. Please reinstall the app.")
                
                )
            } else {
                ContentView()
                    .environmentObject(viewModel)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
