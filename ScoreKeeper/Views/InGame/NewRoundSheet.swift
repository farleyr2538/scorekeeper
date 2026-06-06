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
            
            ScrollView {
                
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
                        
                        
                    } else {
                        ProgressView("Loading scores...")
                            .onAppear {
                                scoreBuffers = viewModel.newRound(game: currentGame)
                            }
                    }
                    
                    Spacer()
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
                        
                        Button("Add round") {
                            
                            print("Add button pressed")
                            
                            do {
                                print("trying to add round")
                                try viewModel.addRound(
                                    scores: scoreBuffers,
                                    game: currentGame,
                                    indexOfNegativeNumbers: indexOfNegativeNumbers
                                )
                                print("round added")
                                
                                // increment roundsPlayed
                                currentGame.roundsPlayed += 1
                                
                                try context.save()
                                print("game saved")
                                
                            } catch addRoundError.invalidScore {
                                errorMessage = "Invalid score entered"
                                isError = true
                            } catch {
                                errorMessage = "Unknown error"
                                isError = true
                            }
                            
                            // dismiss sheet
                            if !isError {
                                newRoundSheetShowing = false
                            }
                            
                        }
                        .buttonStyle(.borderedProminent)
                        
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
            } // end of ScrollView
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
