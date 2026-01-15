//
//  EditRoundSheet.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 14/07/2025.
//

import SwiftUI
import SwiftData

struct EditRoundSheet: View {
    
    @EnvironmentObject var viewModel : ViewModel
    
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @State var isError : Bool = false
    @State var errorMessage : String = ""
    
    @Bindable var game : Game
    
    @Binding var editRoundSheetShowing : Bool
    
    @Binding var roundIndex : Int
    
    @State var scoreBuffers : [String] = []
        
    var numberFormatter = NumberFormatter()
    
    var body: some View {
        
        VStack {
            
            Text("Edit Round \(roundIndex + 1)")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            
            if scoreBuffers.count == game.players.count {
                ForEach(game.players.indices, id: \.self) { index in
                    
                    HStack {
                        Text(game.players[index].name)
                        Spacer()
                        TextField("0", text: $scoreBuffers[index])
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 75)
                            .keyboardType(.numberPad)
                    }
                    .frame(width: 200)
                }
                Button("Update") {
                    
                    // edit each player's scores array accordingly
                    
                    // for the index of each player...
                    game.players.indices.forEach { index in
                        
                        // get the score at that index in scoreBuffers (which we have updated) and try to cast it to an Int
                        if let score = Int(scoreBuffers[index]) {
                            // assign the player at that index the corresponding score at that index, for the round we are on (roundIndex)
                            game.players[index].scores[roundIndex] = score
                        } else {
                            // error
                            errorMessage = "Unable to update scores"
                            isError = true
                        }
                        
                    }
                    
                    // and re-calculate their scores
                    game.players.forEach { player in
                        viewModel.recalculateScores(player: player, halving: game.halving)
                    }
                    
                    do {
                        try context.save()
                        print("game saved after round edit")
                    } catch {
                        print("failed to save game after round edit")
                    }
                    
                    // dismiss sheet
                    dismiss()
                }
                .padding()
                .buttonStyle(.bordered)
            } else {
                ProgressView("Loading scores...")
                    .onAppear {
                        scoreBuffers = viewModel.getScores(game: game, roundIndex: roundIndex)
                    }
            }
        }
        .padding(.top, 20)
        .padding(.horizontal)
        .alert("Error", isPresented: $isError) {
            Button("Cancel") {
                editRoundSheetShowing = false
            }
        } message: {
            Text(errorMessage)
        }
        
    }
}

#Preview {
    
    EditRoundSheet(
        game: Game(
            players: [
                Player(
                    name: "Rob",
                    scores: [0, 0, 25],
                    runningScores: []
                ),
                Player(
                    name: "Flora",
                    scores: [5, 3, 15],
                    runningScores: []
                ),
                Player(
                    name: "Vnesh",
                    scores: [9, 12, 0],
                    runningScores: []
                )
            ],
            halving: true
        ),
        editRoundSheetShowing: .constant(true),
        roundIndex: .constant(0)
    )
    .environmentObject(ViewModel())
}
