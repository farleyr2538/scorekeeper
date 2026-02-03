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
    @Binding var playerToEdit : Player
    
    @State var currentScoreString : String = ""
            
    var numberFormatter = NumberFormatter()
    
    var body: some View {
        
        let playerName = playerToEdit.name
        let currentScore = playerToEdit.scores[roundIndex]
        
        VStack {
            
            Text("Edit \(playerName)'s Round \(roundIndex + 1)")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            
            
            HStack {
                Text(playerName)
                Spacer()
                TextField("0", text: $currentScoreString)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 75)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            .frame(width: 200)
                
            Button("Update") {
                    
                    // edit each player's scores array accordingly
                    
                    // for the index of each player...
                if let newScore = Int(currentScoreString) {
                    playerToEdit.scores[roundIndex] = newScore
                }
                
                viewModel.recalculateScores(player: playerToEdit, halving: game.halving)
                    
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
        }
        .padding(.top, 20)
        .padding(.horizontal)
        
        .onAppear {
            currentScoreString = String(currentScore)
        }
        
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
        roundIndex: .constant(0),
        playerToEdit: .constant(Player(name: "Jerry", scores: [0, 1, 4], runningScores: [0, 1, 5]))
    )
    .environmentObject(ViewModel())
}
