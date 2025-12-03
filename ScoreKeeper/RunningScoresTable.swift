//
//  RunningScoresTable.swift
//  Yanev
//
//  Created by Robert Farley on 25/06/2025.
//

import SwiftUI

struct RunningScoresTable: View {
    
    @EnvironmentObject var viewModel : ViewModel
    @Binding var currentGame : Game
    
    var body: some View {
        
        ScrollView {
            VStack {
                HStack {
                    
                    ForEach(currentGame.players) { player in
                        VStack(alignment: .center) {
                            
                            Text(player.name)
                                .bold()
                                .padding(.bottom, 5)
                            
                            let scores = player.runningScores
                            
                            ForEach(Array(scores.enumerated()), id: \.offset) { scoreIndex, score in
                                ScoreNumber(score: score, context: .runningScores, roundIndex: scoreIndex)
                            }
                        }
                    }
                }
                Spacer()
                Text("Running totals")
                    .font(.caption)
                    .padding(.bottom, 40)
                    .padding(.top, 20)
            }
            .padding(.top)
        }
        
    }
}

#Preview {
    RunningScoresTable(currentGame: .constant(
        Game(
            players: [
                
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
    ))
}

