//
//  CreateGameView.swift
//  Yanev
//
//  Created by Robert Farley on 22/06/2025.
//

import SwiftUI
import SwiftData

struct CreateGameView: View {
    
    @EnvironmentObject private var viewModel : ViewModel
    @Environment(\.modelContext) var context
            
    @Bindable var game : Game = Game(players: [], halving: true, lowestWins: true)
    
    @State var newPlayerSheetShowing : Bool = false
    
    @State var isGameError : gameError?
    @State var errorText : String = ""
    @State var showAlert = false
    @State var startButtonPressed : Bool = false
    
    @State var gameID : UUID?
    @State var gameStarted = false
    @State var gameName = ""
        
    var body: some View {
        
        VStack { // enclosing VStack
            
            VStack {
                
                // players
                PlayersView(game: game, newPlayerSheetShowing: $newPlayerSheetShowing)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                
                // game settings
                GameSettings(game: game)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .padding(.top, 15)
                    .frame(width: 300)
                
                VStack(alignment: .leading) {
                    Text("Game Name (optional):")
                        .font(.headline)
                    TextField("eg. 'Yaniv', 'Uno', 'Whist' etc.", text: $gameName)
                        .padding(5)
                        .clipShape(RoundedRectangle(cornerRadius: 15.0))
                        //.border(.gray)
                        .background(.white)
                        .autocorrectionDisabled()
                }
                .padding(.bottom, 35)
                .padding(.top, 15)
                .padding(.horizontal, 30)
                .frame(width: 300)
                
                
            }
            .background(Color.brown.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(50)
            .navigationTitle("Create Game")
            
            Spacer()
            
            Button {
                
                // abstract this out to ViewModel
                
                // verify game is valid
                do {
                    try viewModel.verifyGame(game: game)
                } catch let error as gameError {
                    switch error {
                    case .noPlayers:
                        errorText = "Please add players before starting"
                        showAlert = true
                    case .tooManyPlayers:
                        errorText = "There is a maximum of seven players"
                        showAlert = true
                    }
                } catch {
                    errorText = "Unexpected error"
                    showAlert = true
                }
                
                // if game is valid, add player names to player history
                game.players.forEach { player in
                    if !viewModel.allPlayers.contains(where: { $0 == player.name }) {
                        viewModel.addPlayerName(player.name)
                    }
                }
                
                // add an initial '0' score to each player
                game.players.forEach { player in
                    viewModel.addScore(
                        player: player,
                        score: 0,
                        halving: false
                    )
                }
                
                // increment roundsPlayed accordingly
                game.roundsPlayed += 1
                
                // add the game to persistent memory
                context.insert(game)
                
                // try to save
                do {
                    try context.save()
                    gameID = game.id
                    print("context saved at game creation")
                    print("game ID being passed: \(game.id.uuidString)")
                    print("number of players in game: \(game.players.count)")
                    
                    // start game
                    if !showAlert {
                        gameStarted = true
                    }
                    
                } catch {
                    print("unable to save game")
                }
            } label: {
                FullWidthButton(text: "Start")
                    .padding(.horizontal)
            }
            .scaleEffect(startButtonPressed ? 0.9 : 1.0)
            .animation(.spring(), value: startButtonPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0.0)
                    .onChanged { _ in startButtonPressed = true }
                    .onEnded { _ in startButtonPressed = false }
            )
            
            .sheet(isPresented: $newPlayerSheetShowing) {
                AddPlayerSheet(
                    game: game,
                    newPlayerSheetShowing: $newPlayerSheetShowing
                )
                .presentationDetents([.medium, .large])
            }
            .alert("Error creating game", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(errorText)
            }
        }
        .navigationDestination(isPresented: $gameStarted) {
            if let gameID = gameID {
                GameView(id: gameID)
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

#Preview {
    CreateGameView()
        .environmentObject(ViewModel())
}
