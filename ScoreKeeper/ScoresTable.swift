//
//  TableView.swift
//  Yanev
//
//  Created by Robert Farley on 25/06/2025.
//

import SwiftUI

struct ScoresTable: View {
    
    @Binding var currentGame : Game
    
    var body: some View {
                
        ScrollView {
            VStack {
                HStack(alignment: .top) {
                    
                    // one vstack here with row labels
                    
                    VStack(alignment: .leading) {
                        Text("#")
                            .bold()
                            .padding(.bottom, 5)
                            .hidden()
                        ForEach(currentGame.players[0].scores.values.indices, id: \.self) { index in
                            Text(String(index + 1))
                                .padding(.bottom, 1)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    
                                        
                    ForEach(currentGame.players.indices, id:\.self) { index in
                        
                        let player = currentGame.players[index]
                        
                        VStack(alignment: .center) {
                            
                            Text(player.name)
                                .bold()
                                .padding(.bottom, 5)
                            
                            let scores = Array(player.scores.values)
                            
                            ForEach(Array(scores.enumerated()), id: \.offset) { scoreIndex, score in
                                
                                ScoreNumber(score: score, context: .scores)
                                
                                // check if we're not on the last item in the array
                                // if so, check if the next number is negative
                                // if so, print a crossed-out version of the current value, and print the negative number just next to it
                                // else, just print score as normal
                                
                                /*
                                if currentGame.halving && scoreIndex < scores.count - 1 && scores[scoreIndex + 1] < 0 {
                                    HalvedScore(
                                        previousScore: score,
                                        halvedScore: scores.values[scoreIndex + 1]
                                    )
                                    // index += 1
                                    
                                } else {
                                    ScoreNumber(score: score)
                                }
                                 */
                            }
                        }
                    }
                }

                HStack {
                    VStack(alignment: .leading) {
                        Text("#")
                            .hidden()
                        Text("Totals:")
                            .foregroundStyle(Color.gray)
                    }
                    //.padding(.leading, 10)
                    
                    
                    ForEach(currentGame.players.indices, id:\.self) { index in
                        let player = currentGame.players[index]
                        if !player.scores.values.isEmpty {
                            VStack {
                                Text(player.name)
                                    .hidden()
                                Text(String(player.total))
                                    .bold()
                            }
                        }
                    }
                    
                }
                //.padding(.trailing, 30)
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        Text("#")
                            .hidden()
                        Text("Average:")
                            .foregroundStyle(Color.gray)
                    }
                    //.padding(.leading, 10)
                    
                    // Spacer()
                    
                    ForEach(currentGame.players.indices, id:\.self) { index in
                        let player = currentGame.players[index]
                        if !player.scores.values.isEmpty {
                            VStack {
                                Text(player.name)
                                    .hidden()
                                Text("\(String(format: "%.1f", player.average))")
                            }
                        }
                    }
                }
                //.padding(.trailing, 50)
                
                //Spacer()
                
                Text("Individual rounds")
                    .font(.caption)
                    .padding(.vertical, 30)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    ScoresTable(currentGame: .constant(
        Game(
            players: [
                /*
                Player(name: "Rob", scores: [0, 0, 25]),
                Player(name: "Flora", scores: [5, 3, 15]),
                Player(name: "Vnesh", scores: [9, 12, 0])
                */
                /*
                Player(name: "Rob", scores: []),
                Player(name: "Flora", scores: []),
                Player(name: "Vnesh", scores: [])
                 */
                /* */
                Player(
                    name: "Rob",
                    scores: intArray(
                        values: [29, 0, 14, 0, 15, 21, 2, 10, 0, 0, 5, 10, 35, 15, 0, 0, 0]),
                    runningScores: intArray(values: [])
                ),
                Player(
                    name: "Flora",
                    scores: intArray(values: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14]),
                    runningScores: intArray(values: [])
                ),
                Player(
                    name: "Vnesh",
                    scores: intArray(values: [0, 3, 0, 7, 0, 0, 0, 26, 9, 12, 0, 0, 11, 0, 7, 6, 19, -50]),
                    runningScores: intArray(values: [])
                )
                /*,
                Player(
                    name: "Rob",
                    scores: intArray(
                        values: [29, 0, 14, 0, 15, 21, 2, 10, 0, 0, 5, 10, 35, 15, 0, 0, 0]),
                    runningScores: intArray(values: [])
                ),
                Player(
                    name: "Flora",
                    scores: intArray(values: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14]),
                    runningScores: intArray(values: [])
                ),
                Player(
                    name: "Vnesh",
                    scores: intArray(values: [0, 3, 0, 7, 0, 0, 0, 26, 9, 12, 0, 0, 11, 0, 7, 6, 19, -50]),
                    runningScores: intArray(values: [])
                ),
                Player(
                    name: "Flora",
                    scores: intArray(values: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14]),
                    runningScores: intArray(values: [])
                )
                 */
            ],
            halving: true
        )
    ))
}
