//
//  AveragesView.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 05/07/2025.
//

import SwiftUI
import SwiftData

struct AveragesView: View {
    
    @EnvironmentObject var viewModel : ViewModel
    @Bindable var game : Game
    
    var body: some View {
    
        VStack {
            ForEach(game.players) { player in
                
                let avg = player.average
                
                HStack {
                    Text(player.name)
                    Spacer()
                    if avg.isNaN {
                        Text("N/A")
                    } else {
                        Text(String(format: "%.1f", avg))
                    }
                    
                }
                .padding(.bottom, 1)
            }
        }
        .padding()
        //.navigationTitle("Average Scores")
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    AveragesView(game:
        Game(players: [
            Player(
                name: "Rob",
                scores: [],
                runningScores: [29, 29, 43, 43, 58, 79, 81, 91, 91, 91, 96, 106, 141, 156, 156, 156, 156]
            ),
            Player(
                name: "Flora",
                scores: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14],
                runningScores:  [36, 49, 65, 78, 102, 123, 129, 129, 159, 195, 208, 257, 260, 299, 306, 351, 365]
            ),
            Player(
                name: "Vnesh",
                scores: [0, 3, 0, 7, 0, 0, 0, 26, 9, 12, 0, 0, 11, 0, 7, 6, 19],
                runningScores: [0, 3, 3, 10, 10, 10, 10, 36, 45, 57, 57, 57, 68, 68, 75, 81, 100]
                )
            ],
            halving: true
        )
    )
    .environmentObject(ViewModel())
    .modelContainer(
        for: [Game.self, Player.self],
        inMemory: true
    )
}
