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

    @State var newRoundSheetShowing : Bool = false
    @State var newPlayerSheetShowing : Bool = false
    @State var editRoundSheetShowing : Bool = false
    
    @State var roundIndex : Int = 0
        
    @State var endGameAlertShowing : Bool = false
    
    enum Tab {
        case scoresGridTab
        case leaderboardTab
        case chartTab
    }
    
    @State var selectedTab : Tab = .scoresGridTab
    
    @State var isZoomed : Bool = false
    
    // error handling
    @State var isError : Bool = false
    @State var errorMessage : String = ""
    
    var id : UUID
    
    @Query var games : [Game]
    var game : Game? {
        games.first(where: { $0.id == id })
    }
        
    var body: some View {
        
        if let game = game {
            Group {
                TabView(selection: $selectedTab) {
                    
                    ScoresGrid(
                        currentGame: game,
                        roundToEdit: $roundIndex,
                        editRoundSheetShowing: $editRoundSheetShowing
                    )
                    .navigationTitle("Scores")
                    .tag(Tab.scoresGridTab)
                        
                    ScrollView {
                        Leaderboard(game: game)
                            .frame(width: 350)
                            .padding(.top, 10)
                    }
                    .navigationTitle("Leaderboard")
                    .tag(Tab.leaderboardTab)
                    .font(isZoomed ? .system(size: 40) : .body)
                    .animation(.easeIn, value: isZoomed)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                isZoomed.toggle()
                            } label: {
                                Image(systemName: "plus.magnifyingglass")
                            }
                        }
                    }
                    
                    VStack {
                        ScoreChart(game: game)
                            .tag(Tab.chartTab)
                            .navigationTitle("Progress Chart")
                            .padding()
                        Spacer()
                    }
                    
                        
                        
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
            }
            .alert("Error", isPresented: $isError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
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
                    .onTapGesture {
                        do {
                            try context.save()
                            print("context saved with end of game")
                        } catch {
                            print("failed to save context at end of game")
                        }
                    }
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
                    useContext: .midGame
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
        } else {
            Group {
                VStack(alignment: .center, spacing: 10) {
                    Text("Error: No game found")
                    Text("Game ID received: \(id.uuidString)")
                }
                .foregroundStyle(.gray)
                .frame(width: 350)
            }
        }
    }
}

#Preview {
        
    let previewGame = Game(players: [
        Player(
            name: "Rob",
            scores: [29, 0, 14, 0, 15, 21, 2, 10, 0, 0, 5, 10, 35, 15, 0, 0, 0],
            runningScores: [29, 29, 43, 43, 58, 79, 81, 91, 91, 91, 96, 106, 141, 156, 156, 156, 156]
        ),
        Player(
            name: "Flora",
            scores: [36, 13, 16, 13, 24, 21, 6, 0, 30, 36, 13, 49, 3, 39, 7, 45, 14],
            runningScores: [36, 49, 65, 78, 102, 123, 129, 129, 159, 195, 208, 257, 260, 299, 306, 351, 365]
        ),
        Player(
            name: "Vnesh",
            scores: [0, 3, 0, 7, 0, 0, 0, 26, 9, 12, 0, 0, 11, 0, 7, 6, 19],
            runningScores: [0, 3, 3, 10, 10, 10, 10, 36, 45, 57, 57, 57, 68, 68, 75, 81, 100]
            )
        ],
        halving: true
    )
        
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, Player.self, configurations: config)
    container.mainContext.insert(previewGame)
    
    return GameView(id: previewGame.id)
            .modelContainer(container)
            .environmentObject(ViewModel())
}
