//
//  ScoresGrid.swift
//  Yanev
//
//  Created by Robert Farley on 28/06/2025.
//

import SwiftUI

struct ScoresGrid: View {
    
    @EnvironmentObject var viewModel : ViewModel
    
    @Bindable var game : Game
    @Binding var roundToEdit : Int
    @Binding var editRoundSheetShowing : Bool
    
    var minScore : Int {
        var minSoFar : Int = game.players.first!.total
        game.players.forEach { player in
            if player.total < minSoFar {
                minSoFar = player.total
            }
        }
        return minSoFar
    }
    
    var maxScore : Int {
        var maxSoFar : Int = game.players.first!.total
        game.players.forEach { player in
            if player.total > maxSoFar {
                maxSoFar = player.total
            }
        }
        return maxSoFar
    }
    
    var grey : Bool = false
    
    var body: some View {
        
        let winners = game.winners
        
        let maxRounds = game.players.map { $0.scores.count }.max() ?? 0
        
        VStack(spacing: 0) {

            ScrollView(.vertical, showsIndicators: false) {
                
                Grid {
                    
                    // names row
                    GridRow {
                 
                        ForEach(game.players) { player in
                            
                            VStack {
                                
                                Spacer()
                                
                                if winners.count == 1 && winners.contains(player) {
                                        
                                    Image(systemName: "crown")
                                        .foregroundStyle(.yellow)
                                        .padding(.bottom, 1)
                                    
                                } else {
                                    Image(systemName: "crown")
                                        .padding(.bottom, 1)
                                        .hidden()
                                }
                                
                                Text(player.name)
                                    .bold()
                                    .gridColumnAlignment(.center)
                            }
                        }
                    }
                    .font(.headline)
                    
                    GridRow {
                        Divider()
                            .gridCellColumns(game.players.count + 1)
                            .overlay(Color.gray)
                    }
                    
                    ForEach(0..<maxRounds, id: \.self) { roundIndex in

                        GridRow {
                                                        
                            // for each player
                            ForEach(game.players) { player in
                                
                                // get their scores array
                                let playersScores = player.scores
                                
                                Group {
                                    // if the roundIndex is within their range
                                    if roundIndex < playersScores.count {
                                        // print their score
                                        ScoreNumber(score: playersScores[roundIndex], context: .scores, roundIndex: roundIndex
                                        )
                                    } else {
                                        // otherwise, print blank space
                                        Text("")
                                    }
                                }
                                .gridColumnAlignment(.center)
                                
                            }
                            
                            
                        }
                        .onTapGesture {
                            roundToEdit = roundIndex
                            editRoundSheetShowing = true
                        }
                    }
                } // end of Grid
                .fixedSize(horizontal: true, vertical: false)
                //.padding(.top, 10)
                
            } // end of Scrollview
            
            Grid(alignment: .top) {
                
                GridRow {
                    ForEach(game.players, id: \.self) { player in
                        Text("\(player.total)")
                    }
                }
                .bold()
                .padding(.top)
                .padding(.bottom, 30)
                
                GridRow { // invisible row to ensure correct column width
                    
                    ForEach(game.players) { player in
                        Text(player.name)
                            .bold()
                            .gridColumnAlignment(.center)
                            .hidden()
                    }
                }
            }
        } // end of VStack
    }
}

#Preview {
    ScoresGrid(game:
        Game(
            players: [
                
                Player(
                    name: "Rob",
                    scores: [29, 0, 14, 0, 15, 21, 2, 10, 0, 0, 5, 10, 35, 15, 0, 0, 0],
                    runningScores: []
                ),
                Player(
                    name: "Flora",
                    scores: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14],
                    runningScores: []
                ),
                Player(
                    name: "Vnesh",
                    scores: [0, 3, 0, 7, 0, 0, 0, 26, 9, 12, 0, 0, 11, 0, 7, 6, 19, -50],
                    runningScores: []
                )
                
                 
            ],
            halving: true
        ), roundToEdit: .constant(1), editRoundSheetShowing: .constant(false)
    )
    .environmentObject(ViewModel())
}
