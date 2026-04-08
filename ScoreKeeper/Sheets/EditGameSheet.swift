//
//  EditGameSheet.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 16/02/2026.
//

import SwiftUI

struct EditGameSheet: View {
    
    @EnvironmentObject var viewModel : ViewModel
    @Environment(\.modelContext) var context
    
    @Bindable var game : Game
    
    @Binding var gameName : String
    @Binding var lowestWins : Bool
    @Binding var halving : Bool
    
    @Binding var editGameSheetShowing : Bool
    
    @State var deletePlayerAlertShowing : Bool = false
    @State var renamePlayerAlertShowing : Bool = false
    
    @State var playerToDelete : Player? = nil
    @State var playerToRename : Player? = nil
    
    @State var playerNameBuffer : String = ""
    
    @State var showErrorAlert : Bool = false
    @State var errorMessage : String = ""
    
    @Binding var markPracticeRounds : Bool
    
    var body: some View {
        
        NavigationStack {
            
            // ScrollView {
                
                VStack {
                    // game settings
                    HStack {
                        Text("Edit Game")
                            .font(.title.bold())
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    Divider()
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 20) {
                        
                        HStack(spacing: 20) {
                            Text("Game name")
                            TextField("eg. Yaniv", text: $gameName)
                                .presentationDetents([.medium])
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Toggle("Lowest score wins", isOn: $lowestWins)
                        
                        Toggle("Halving", isOn: $halving)
                        
                    }
                    .padding(.bottom, 20)
                    
                    // edit players
                    VStack(spacing: 15) {
                        
                        HStack {
                            Text("Edit Players")
                                .font(.headline)
                            Spacer()
                        }
                        
                        ForEach(game.players, id: \.persistentModelID) { player in
                            
                            // option to re-name or delete player
                            HStack(spacing: 10) {
                                Text(player.name)
                                
                                Image(systemName: "pencil")
                                    .onTapGesture {
                                        playerNameBuffer = player.name
                                        playerToRename = player
                                        renamePlayerAlertShowing = true
                                    }
                                
                                Spacer()
                                
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                                    .onTapGesture {
                                        playerToDelete = player
                                        deletePlayerAlertShowing = true
                                    }
                            }
                            
                            
                            //.frame(maxWidth: 250)
                        }
                        
                        .alert("Rename Player", isPresented: $renamePlayerAlertShowing) {
                            TextField("", text: $playerNameBuffer)
                            Button("Save") {
                                playerToRename?.name = playerNameBuffer
                                try? context.save()
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                        
                        .alert("Remove \(playerToDelete?.name ?? "this player") from the game?", isPresented: $deletePlayerAlertShowing, ) {
                            
                            Button("Yes", role: .destructive) {
                                if playerToDelete != nil {
                                    game.players.removeAll { $0.persistentModelID == playerToDelete?.persistentModelID }
                                    
                                    try? context.save()
                                } else {
                                    print("error: playerToDelete is nil")
                                }
                            }
                            
                            Button("No", role: .cancel) {}
                            
                        } message: {
                            Text("This will delete all their scores from the game.")
                        }
                        
                        .alert("Error", isPresented: $showErrorAlert) {
                            Button("OK") {}
                        } message: {
                            Text("Unable to delete player. Please try again.")
                        }
                        
                        Button {
                            editGameSheetShowing = false
                            markPracticeRounds = true
                        } label: {
                            Text("Delete Rounds")
                                .padding(5)
                        }
                        .padding(.top, 10)
                        .buttonStyle(.bordered)
                        
                        HStack {
                            
                            Spacer()
                            
                            Button {
                                editGameSheetShowing = false
                            } label: {
                                Text("Cancel")
                                    .padding(10)
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button {
                                game.name = gameName
                                game.lowestWins = lowestWins
                                
                                if !viewModel.gameNames.contains(gameName) {
                                    viewModel.gameNames.append(gameName)
                                }
                                
                                try? context.save()
                                
                                editGameSheetShowing = false
                            } label: {
                                Text("Save")
                                    .padding(10)
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Spacer()
                        }
                        .padding(.vertical)
                        
                    }
                    
                    Spacer()
                    
                } // end of the VStack container
                .padding(.horizontal, 30)
                .padding(.top, 40)
                
            // } // end of ScrollView
            
            
        }
    }
}

#Preview {
    EditGameSheet(
        game: Game.sampleGames.first!,
        gameName: .constant("Yaniv"),
        lowestWins: .constant(false),
        halving: .constant(false),
        editGameSheetShowing: .constant(true),
        markPracticeRounds: .constant(false)
    )
        .environmentObject(ViewModel())
}
