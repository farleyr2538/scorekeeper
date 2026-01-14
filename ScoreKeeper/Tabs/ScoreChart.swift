//
//  Chart.swift
//  Yanev
//
//  Created by Robert Farley on 29/06/2025.
//

import SwiftUI
import Charts

struct ScoreChart: View {
    
    @Bindable var game : Game
    
    var body: some View {
        
        ScrollView(.vertical) {
            
            LazyVStack {
                
                Group {
                    if game.roundsPlayed < 2 {
                        HStack {
                            Spacer()
                            Text("Not enough rounds for a chart")
                                .foregroundStyle(.gray)
                            Spacer()
                        }
                    } else {
                        Chart {
                            
                            ForEach(game.players) { player in
                                
                                LineMark(
                                    x: .value("Round", 0),
                                    y: .value("Score", 0)
                                )
                                .foregroundStyle(by: .value("Player", player.name))
                                .symbol(by: .value("Player", player.name))
                                
                                ForEach(Array(player.runningScores.enumerated()), id: \.offset) { index, score in
                                    LineMark(
                                        x: .value("Round", index + 1),
                                        y: .value("Score", score)
                                    )
                                    .foregroundStyle(by: .value("Player", player.name))
                                    .symbol(by: .value("Player", player.name))
                                }
                            }
                        }
                    }
                }
                .frame(height: 300)
                .padding(.horizontal, 15)
                .containerRelativeFrame([.horizontal, .vertical])
                
                // Spacer()
                
                RunningScoresTable(currentGame: game)
                    .containerRelativeFrame([.horizontal, .vertical])
                
            }
            
        }
        .scrollTargetBehavior(.paging)
        
    }
}

#Preview {
    ScoreChart(
        game:
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
                halving: true,
                roundsPlayed: 17
            )
        
    )
    .modelContainer(for: Player.self, inMemory: true)
}
