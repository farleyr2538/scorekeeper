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
    @Binding var roundIndex : Int
    @Binding var editRoundSheetShowing : Bool
    
    @State var playerToEdit : Player = Player(name: "", scores: [], runningScores: [])
    
    @Binding var markPracticeRounds : Bool
    
    @Binding var selectedRounds : [Int]
    @State var deleteRoundAlert : Bool = false
        
    var minScore : Double {
        var minSoFar : Double = game.players.first!.total
        game.players.forEach { player in
            if player.total < minSoFar {
                minSoFar = player.total
            }
        }
        return minSoFar
    }
    
    var maxScore : Double {
        var maxSoFar : Double = game.players.first!.total
        game.players.forEach { player in
            if player.total > maxSoFar {
                maxSoFar = player.total
            }
        }
        return maxSoFar
    }
    
    var grey : Bool = false
    
    func formatScore(_ score: Double) -> String {
        if score.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(score))
        } else {
            return String(score)
        }
    }
    
    var body: some View {
        
        let winners = game.winners
        
        let maxRounds = game.players.map { $0.scores.count }.max() ?? 0
        
        let maxFilteredRounds = game.players.map { $0.filteredScores.count }.max() ?? 0
        
        VStack(spacing: 0) {

            ScrollView(.vertical, showsIndicators: false) {
                
                Grid {
                    
                    // names row
                    GridRow {
                        
                        if markPracticeRounds {
                            Spacer()
                        }
                 
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
                    
                    // scores
                    ForEach(0..<maxRounds, id: \.self) { index in
                        
                        let roundIsSelected = selectedRounds.contains(index)

                        GridRow {
                            
                            if markPracticeRounds && index < maxFilteredRounds {
                                
                                Image(systemName: roundIsSelected ? "checkmark.circle.fill" : "circle")
                                    .imageScale(Image.Scale.large)
                                    .foregroundStyle(roundIsSelected ? .blue : .gray)
                                    .onTapGesture {
                                        if roundIsSelected {
                                            selectedRounds.removeAll(where: { $0 == index })
                                        } else {
                                            selectedRounds.append(index)
                                        }
                                    }
                            }
                                                        
                            // for each player
                            ForEach(game.players) { player in
                                
                                if !markPracticeRounds {
                                    
                                    // get their scores array
                                    let playersScores = player.scores
                                    
                                    Group {
                                        // if the roundIndex is within their range
                                        if index < playersScores.count {
                                            
                                            // print their score
                                            ScoreNumber(
                                                score: playersScores[index],
                                                context: .scores,
                                                roundIndex: roundIndex
                                            )
                                            .onTapGesture {
                                                // playerID: player.id? player index?
                                                playerToEdit = player
                                                roundIndex = index
                                                editRoundSheetShowing = true
                                            }
                                            
                                        } else {
                                            // print blank space
                                            Text("")
                                        }
                                    }
                                    .gridColumnAlignment(.center)
                                } else {
                                    
                                    let playersScores = player.filteredScores
                                    
                                    Group {
                                        // if the roundIndex is within their range
                                        if index < playersScores.count {
                                            
                                            // print their score
                                            ScoreNumber(
                                                score: playersScores[index],
                                                context: .scores,
                                                roundIndex: roundIndex
                                            )
                                            
                                        } else {
                                            // print blank space
                                            Text("")
                                        }
                                    }
                                    .gridColumnAlignment(.center)
                                }
                                
                            }
                        }                        
                    }
                } // end of Grid
                .fixedSize(horizontal: true, vertical: false)
                //.padding(.top, 10)
                
            } // end of Scrollview
            
            Grid { // totals row
                
                GridRow { // totals
                    ForEach(game.players, id: \.self) { player in
                        Text(formatScore(player.total))
                    }
                }
                .bold()
                .padding(.top)
                .padding(.bottom, 20)
                
                GridRow { // invisible row to ensure correct column width
                    
                    ForEach(game.players) { player in
                        Text(player.name)
                            .bold()
                            .gridColumnAlignment(.center)
                            .hidden()
                    }
                }
            }
            
            /*
            if markPracticeRounds {
                HStack {
                    
                    Button(role: .destructive) {
                        deleteRoundAlert = true
                    } label: {
                        Text("Delete")
                            .padding(5)
                    }
                    .buttonStyle(.bordered)
                    .disabled(selectedRounds.count == 0)
                }
                .alert("Delete Round?", isPresented: $deleteRoundAlert) {
                    Button("Delete", role: .destructive) {
                        
                        // remove halves/negative scores
                        for player in game.players {
                            player.scores = player.filteredScores
                        }
                        
                        // sort index list descending
                        let sortedIndexList = selectedRounds.sorted { $0 > $1 }
                        print(sortedIndexList)
                        
                        for index in sortedIndexList { // for each index we should remove
                            // for each player, remove his score at [index] position
                            for player in game.players {
                                player.scores.remove(at: index)
                            }
                        }
                        
                        // de-increment roundsPlayed by number of rounds deleted
                        game.roundsPlayed -= sortedIndexList.count
                    }
                } message: {
                    Text("Are you sure you want to delete the selected rounds?")
                }
            }
             */
            
            Spacer()
            
        } // end of VStack
        
        // edit round sheet
        .sheet(isPresented: $editRoundSheetShowing) {
            EditRoundSheet(
                game: game,
                editRoundSheetShowing: $editRoundSheetShowing,
                roundIndex: $roundIndex,
                playerToEdit: $playerToEdit
            )
            .presentationDetents([.medium, .large])
        }
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
        ), roundIndex: .constant(1),
               editRoundSheetShowing: .constant(false),
               markPracticeRounds: .constant(true),
               selectedRounds: .constant([])
    )
    .environmentObject(ViewModel())
}
