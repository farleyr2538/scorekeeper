//
//  NewRoundSheet.swift
//  Yanev
//
//  Created by Robert Farley on 23/06/2025.
//

import SwiftUI
import SwiftData

struct NewRoundSheet: View {
    
    @EnvironmentObject private var viewModel : ViewModel
    @Environment(\.modelContext) var context
    
    @Bindable var currentGame : Game
    
    @Binding var newRoundSheetShowing : Bool
    
    @State var scoreBuffers : [String] = []
    @State var scores : [Double] = []
    
    // error
    @State var errorMessage : String = ""
    @State var isError : Bool = false
    
    // focus
    @FocusState private var focusedField : Int?
    
    var numberFormatter = NumberFormatter()
    
    @State var indexOfNegativeNumbers : [Int] = []
    
    var body: some View {
        
        NavigationStack {
            VStack {
                
                Text("Add New Round")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 20)
                
                if scoreBuffers.count == currentGame.players.count {
                    
                    ForEach(currentGame.players.indices, id: \.self) { index in
                        PlayerScoreRow(
                            player: $currentGame.players[index],
                            scoreBuffer: $scoreBuffers[index],
                            indexOfNegativeNumbers: $indexOfNegativeNumbers,
                            focusedField: $focusedField,
                            index: index
                        )
                    }
                    
                    Button {
                        
                        // validate values
                        // for each value in scorebuffers, confirm that it is not null, and that it can be converted to an int
                        if !viewModel.checkRoundInput(scoreBuffers: scoreBuffers) {
                            // there is at least 1 invalid value
                            errorMessage = "Scores must be a number"
                            isError = true
                        } else {
                            // add scores to each player's scores array
                            currentGame.players.indices.forEach { index in
                                
                                // a copy of this player's score this round
                                if let nominalScore = Double(scoreBuffers[index]) {
                                    
                                    var realScore : Double
                                    
                                    if indexOfNegativeNumbers.contains(index) {
                                        realScore = 0 - nominalScore
                                    } else {
                                        realScore = nominalScore
                                    }
                                    
                                    // add score to scores and runningScores, halving if necessary
                                    viewModel.addScore(
                                        player: currentGame.players[index],
                                        score: realScore,
                                        halving: currentGame.halving
                                    )
                                    
                                } else {
                                    errorMessage = "Unable to convert \(currentGame.players[index].name)'s score: \(scoreBuffers[index]). Please try again."
                                    isError = true
                                }
                            }
                            
                            // increment roundsPlayed
                            currentGame.roundsPlayed += 1
                            
                            do {
                                try context.save()
                                print("game saved after round added")
                            } catch {
                                print("failed to save game after round added")
                            }
                            
                            // dismiss sheet
                            if !isError {
                                newRoundSheetShowing = false
                            }
                            
                        }
                    } label: {
                        Text("Add")
                            .padding(5)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 15)
                } else {
                    ProgressView("Loading scores...")
                        .onAppear {
                            scoreBuffers = viewModel.newRound(game: currentGame)
                        }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = 0
                    print("focusField set to 0")
                }
            }
            
            .alert("Error", isPresented: $isError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        newRoundSheetShowing = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    
                    Spacer()
                    
                    Button {
                        guard let currentFocus = focusedField, currentFocus > 0 else { return }
                        focusedField = currentFocus - 1
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(focusedField == 0)
                    
                    Button {
                        guard let currentFocus = focusedField, currentFocus < currentGame.players.count - 1 else { return }
                        focusedField = currentFocus + 1
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(focusedField == currentGame.players.count - 1)
                }
            }
        }
        
    }
}

#Preview {
        
    NewRoundSheet(
        currentGame: Game(
            players: [
                Player(
                    name: "Rob",
                    scores:[0, 0, 25],
                    runningScores: []
                ),
                Player(
                    name: "Flora",
                    scores: [5, 3, 15],
                    runningScores: []
                ),
                Player(
                    name: "Vnesh",
                    scores: [],
                    runningScores: []
                )
            ],
            halving: true
        ),
        newRoundSheetShowing: .constant(true)
    )
    .environmentObject(ViewModel())
}
