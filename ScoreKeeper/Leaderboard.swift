//
//  Leaderboard.swift
//  Yanev
//
//  Created by Robert Farley on 29/06/2025.
//

import SwiftUI

struct Leaderboard: View {
    
    @Bindable var game : Game
    
    var body: some View {
        
        let length = game.players.count
        
        VStack {
        
            VStack {
                 
                ForEach(Array(game.players.sorted { (p1, p2) in
                    if p1.total != p2.total {
                        if game.lowestWins {
                            return p1.total < p2.total
                        } else {
                            return p1.total > p2.total
                            
                        }
                    } else {
                        if game.lowestWins {
                            return p1.name < p2.name
                        } else {
                            return p1.name > p2.name
                        }
                    }
                }.enumerated()), id: \.offset) { index, player in
                    VStack {
                        HStack {
                            Text(String(index + 1))
                                .foregroundStyle(.gray)
                            Text(player.name)
                            if index == 0 {
                                Image(systemName: "crown")
                                    .foregroundStyle(.yellow)
                            }
                            Spacer()
                            Text(String(player.total))
                        }
                        .padding(.bottom, index == length - 1 ? 10 : 0)
                        if index != length - 1 {
                            Divider()
                        }
                        
                    }
                    .padding(.bottom, 5)
                }
            }
            .padding(.horizontal, 15)
            .padding(.top, 15)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Spacer()
            
        }
        .frame(maxWidth: 450)
        
    }
}

#Preview {
    Leaderboard(
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
                lowestWins: true
        )
    )
}
