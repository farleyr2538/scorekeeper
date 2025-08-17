//
//  PastGames.swift
//  Yanev
//
//  Created by Robert Farley on 24/06/2025.
//

import SwiftUI
import SwiftData

struct GameHistory: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var viewModel : ViewModel
    
    @Query var pastGames : [Game]
    
    func deleteGame(at offsets : IndexSet) {
        for offset in offsets {
            let gameToDelete = pastGames[offset]
            context.delete(gameToDelete)
        }
    }
    
    var body: some View {
        
        // Text("number of past games: \(pastGames.count)")
        
        Group {
            if pastGames.isEmpty {
                Text("No past games")
                    .foregroundStyle(Color.gray)
            } else {
                NavigationStack {
                    List {
                        ForEach(pastGames) { game in
                            
                            let title = viewModel.generateGameTitle(game: game)
                            
                            NavigationLink {
                                GameView(game: game)
                            } label: {
                                Text(title)
                            }
                            
                        }
                        .onDelete(perform: deleteGame)
                    }
                    .navigationTitle("Past Games")
                }
            }
        }
        
        
    }
}

#Preview {
    GameHistory()
        .modelContainer(for: [Game.self, Player.self])
}
