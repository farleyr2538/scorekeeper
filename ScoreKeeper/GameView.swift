//
//  GameView.swift
//  Yanev
//
//  Created by Robert Farley on 23/06/2025.
//

import SwiftUI
import SwiftData

struct GameView: View {
    
    @Environment(\.modelContext) private var context
        
    @Bindable var game : Game
    
    @State var newRoundSheetShowing : Bool = false
    @State var newPlayerSheetShowing : Bool = false
    @State var editRoundSheetShowing : Bool = false
    
    @State var roundIndex : Int = 0
        
    @State var endGameAlertShowing : Bool = false
    
    enum Tab {
        case scoresGridTab
        case leaderboardTab
    }
    
    @State var selectedTab : Tab = .scoresGridTab
        
    var body: some View {
             
        Group {
            if !game.players[0].scores.values.isEmpty {
                TabView(selection: $selectedTab) {
                    
                    ScoresGrid(
                        currentGame: game,
                        roundToEdit: $roundIndex,
                        editRoundSheetShowing: $editRoundSheetShowing
                    )
                    .navigationTitle("Scores")
                        .tag(Tab.scoresGridTab)

                    Leaderboard(game: game)
                        .tag(Tab.leaderboardTab)
                        .navigationTitle("Scoreboard")
                        .padding()
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
            } else {
                VStack {
                    Spacer()
                    Text("No rounds played")
                        .foregroundStyle(Color.gray)
                    Spacer()
                }
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        
        Spacer()
        
        VStack { // VStack for buttons
            Button {
                newRoundSheetShowing = true
            } label: {
                FullWidthButton(text: "Add new round")
            }
            
            HStack(spacing: 25) {
                
                Button {
                    // average in a new player
                    newPlayerSheetShowing = true
                } label: {
                    Text("Add Player")
                        .padding(10)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                
                NavigationLink {
                    FinishedGame(game: game)
                } label: {
                    Text("Finish")
                        .padding(10)
                        .foregroundStyle(Color.blue)
                }
                .clipShape(.capsule)
                .buttonStyle(.bordered)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: 350)
            
        
        // new round sheet
        .sheet(isPresented: $newRoundSheetShowing) {
            NewRoundSheet(
                currentGame: game,
                newRoundSheetShowing: $newRoundSheetShowing
            )
            .presentationDetents([.medium, .large])
        }
        // new player sheet
        .sheet(isPresented: $newPlayerSheetShowing) {
            AddPlayerSheet(
                game: game,
                newPlayerSheetShowing: $newPlayerSheetShowing,
                context: .midGame
            )
            .presentationDetents([.large])
        }
        // edit round sheet
        .sheet(isPresented: $editRoundSheetShowing) {
            EditRoundSheet(
                game: game,
                editRoundSheetShowing: $editRoundSheetShowing,
                roundIndex: $roundIndex
            )
            .presentationDetents([.medium, .large])
        }
            
    }
}

#Preview {
        
    GameView(
        game: Game(players: [
            Player(
                name: "Rob",
                scores: intArray(
                    values: [29, 0, 14, 0, 15, 21, 2, 10, 0, 0, 5, 10, 35, 15, 0, 0, 0]),
                runningScores: intArray(values: [29, 29, 43, 43, 58, 79, 81, 91, 91, 91, 96, 106, 141, 156, 156, 156, 156])
            ),
            Player(
                name: "Flora",
                scores: intArray(values: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14]),
                runningScores: intArray(values: [36, 49, 65, 78, 102, 123, 129, 129, 159, 195, 208, 257, 260, 299, 306, 351, 365])
            ),
            Player(
                name: "Vnesh",
                scores: intArray(values: [0, 3, 0, 7, 0, 0, 0, 26, 9, 12, 0, 0, 11, 0, 7, 6, 19]),
                runningScores: intArray(values: [0, 3, 3, 10, 10, 10, 10, 36, 45, 57, 57, 57, 68, 68, 75, 81, 100])
                )
            ],
            halving: true
        )
    )
    .modelContainer(for: [Game.self, Player.self])
    .environmentObject(ViewModel())
}
