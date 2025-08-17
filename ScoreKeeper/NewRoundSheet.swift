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
    @State var scores : [Int] = []
    
    // error
    @State var errorMessage : String = ""
    @State var isError : Bool = false
    
    // focus
    @FocusState private var focusedField : Int?
    
    var numberFormatter = NumberFormatter()
    
    var body: some View {
        
        VStack {
            
            Text("Add New Round")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            
            if scoreBuffers.count == currentGame.players.count {
                ForEach(currentGame.players.indices, id: \.self) { index in
                    HStack {
                        Text(currentGame.players[index].name)
                        Spacer()
                        TextField("0", text: $scoreBuffers[index])
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 75)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: index)
                    }
                    .frame(width: 200)
                }
                Button("Add") {
                    
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
                            if let thisRoundsScore = Int(scoreBuffers[index]) {
                                // add score to scores and runningScores, halving if necessary
                                viewModel.addScore(
                                    player: currentGame.players[index],
                                    score: thisRoundsScore,
                                    halving: currentGame.halving
                                )
                                currentGame.roundsPlayed += 1
                                
                            } else {
                                errorMessage = "Unable to convert \(currentGame.players[index].name)'s score: \(scoreBuffers[index]). Please try again."
                                isError = true
                            }
                        }
                        
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
                }
                .padding()
                .buttonStyle(.bordered)
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
            focusedField = 0
        }
        .alert("Error", isPresented: $isError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
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
