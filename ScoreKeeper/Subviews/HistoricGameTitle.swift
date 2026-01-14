//
//  HistoricGameTitle.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 04/12/2025.
//

import SwiftUI

struct HistoricGameTitle: View {
    
    @EnvironmentObject var viewModel: ViewModel
    var game: Game
    
    var body: some View {
        
        let  title = viewModel.generateGameTitle(game: game)
        let dateString = game.date.formatted(date: .abbreviated, time: .shortened)
        
        VStack(alignment: .leading) {
            Group {
                if let gameName = game.name {
                    Text(gameName).bold() + Text(title)
                } else {
                    Text("Game") + Text(title)
                }
            }
            Text(dateString)
                .foregroundStyle(.gray)
        }
        
        
        
    }
}

#Preview {
    HistoricGameTitle(game:
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
                        )
    )
        .environmentObject(ViewModel())
}
