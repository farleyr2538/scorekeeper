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
    
    @StateObject var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .modelContainer(for: [
                    Game.self,
                    Player.self
                ])
        }
    }
}
