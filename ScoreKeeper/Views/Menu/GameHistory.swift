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
    
    @Query(sort: \Game.date, order: .reverse) var pastGames : [Game]
        
    func deleteGame(at offsets : IndexSet) {
        for offset in offsets {
            let gameToDelete = pastGames[offset]
            context.delete(gameToDelete)
        }
    }
    
    var body: some View {
                
        Group {
            if pastGames.isEmpty {
                Text("No past games")
                    .foregroundStyle(Color.gray)
            } else {
                NavigationStack {
                    List {
                        ForEach(pastGames) { game in
                                                        
                            NavigationLink {
                                GameView(id: game.id)
                            } label: {
                                HistoricGameTitle(game: game)
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
        .modelContainer(for: [Game.self, Player.self], inMemory: true) { result in
            if case .success(let container) = result {
                Game.sampleGames.forEach { game in
                    container.mainContext.insert(game)
                }
            }
        }
        .environmentObject(ViewModel())
}


