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
    
    // @Query(sort: \Game.date, order: .reverse) var pastGames : [Game]
    
    var pastGames : [Game]
    
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
    GameHistory(
        pastGames: dummyGameData
    )
        .modelContainer(for: [Game.self, Player.self])
        .environmentObject(ViewModel())
}

var dummyGameData = [
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
         name: "Yaniv",
        halving: true
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
        halving: true
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
         name: "Yaniv",
        halving: true
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
        name: "Whist",
        halving: true
         
    )
]
