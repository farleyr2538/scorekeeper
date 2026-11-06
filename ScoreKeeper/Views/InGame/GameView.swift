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
    
    @EnvironmentObject var viewModel : ViewModel

    // sheet control
    @State var newRoundSheetShowing : Bool = false
    @State var newPlayerSheetShowing : Bool = false
    @State var editRoundSheetShowing : Bool = false
    @State var editGameSheetShowing : Bool = false
    
    // alert control
    @State var deleteRoundAlert : Bool = false
    @State var endGameAlertShowing : Bool = false
    
    // the Finish button becomes its own confirmation when armed
    @State var confirmingFinish : Bool = false
    
    @State var markPracticeRounds : Bool = false
    
    @State var gameName : String = ""
    @State var lowestWins : Bool = true
    @State var halving : Bool = false
    
    @State var roundIndex : Int = 0
    @State var selectedRounds : [Int] = []
    
    @State var selectedTab : GameTab = .scoresGridTab

    // whether the chart page has been built yet (see the chart page below)
    @State private var chartPageReady : Bool = false
    
    @State var isZoomed : Bool = false
    
    // scores tab: show running totals instead of individual round scores
    @State var showRunningTotals : Bool = false
    
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
                        game: game,
                        roundIndex: $roundIndex,
                        editRoundSheetShowing: $editRoundSheetShowing,
                        markPracticeRounds: $markPracticeRounds,
                        selectedRounds: $selectedRounds,
                        showRunningTotals: showRunningTotals
                    )
                    .navigationTitle(showRunningTotals && !markPracticeRounds ? "Running Totals" : "Scores")
                    .tag(GameTab.scoresGridTab)
                    .toolbar {
                        if !markPracticeRounds {
                            ToolbarItem(placement: .topBarTrailing) {
                                Toggle(isOn: $showRunningTotals.animation()) {
                                    Label("Running totals", systemImage: "sum")
                                }
                                .toggleStyle(.button)
                            }
                        }
                    }

                    ScrollView {
                        Leaderboard(game: game, isZoomed: isZoomed)
                            // .frame(width: 350)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal)
                    .navigationTitle("Leaderboard")
                    .tag(GameTab.leaderboardTab)
                    .font(isZoomed ? .system(size: 40) : .body)
                    .animation(.easeIn, value: isZoomed)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                isZoomed.toggle()
                            } label: {
                                Image(systemName: isZoomed ? "minus.magnifyingglass" : "plus.magnifyingglass")
                            }
                        }
                    }
                    
                    VStack {
                        // The page view builds the next page in advance, so
                        // without this the chart would be built mid-swipe from
                        // Scores to Leaderboard, making that swipe stutter.
                        // Instead it's built once Leaderboard has been reached.
                        if chartPageReady {
                            ScoreChart(game: game)
                                .padding()
                        }
                        Spacer()
                    }
                    .navigationTitle("Progress Chart")
                    .tag(GameTab.chartTab)
                        
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                // once off the Scores page, build the chart page, and keep it
                .onChange(of: selectedTab) {
                    if selectedTab != .scoresGridTab {
                        chartPageReady = true
                    }
                }
                
            }
            
            .onAppear {
                gameName = game.name ?? ""
                lowestWins = game.lowestWins
                halving = game.halving
            }
            
            .toolbar {
                if markPracticeRounds {
                    ToolbarItem {
                        Button("Cancel") {
                            markPracticeRounds = false
                        }
                    }
                    ToolbarItem {
                        Button(role: .destructive) {
                            deleteRoundAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(Color.red)
                        }
                    }
                } else {
                    // sharing the chart only makes sense while looking at it
                    if selectedTab == .chartTab && game.roundsPlayed >= 2 {
                        ToolbarItem {
                            ShareChartButton(game: game, inProgress: true)
                        }
                    }
                    ToolbarItem {
                        Button {
                            editGameSheetShowing = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
            }
            
            .alert("Error", isPresented: $isError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
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
                    
                    // the remaining rounds have shifted, so move any averaged-in rounds with them
                    viewModel.adjustStartingScoreIndexes(game: game, deletedRoundIndexes: sortedIndexList)
                    
                    // re-calculate scores and halves etc.
                    for player in game.players {
                        viewModel.recalculateScores(player: player, halving: game.halving)
                    }
                    
                    // save context
                    try? context.save()
                    
                    // exit edit mode
                    markPracticeRounds = false
                }
            } message: {
                Text("Are you sure you want to delete the selected rounds?")
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
                    
                    if confirmingFinish {
                        
                        // second tap: actually end the game
                        NavigationLink {
                            FinishedGame(game: game)
                        } label: {
                            Text("End game?")
                                .padding(10)
                                .foregroundStyle(Color.white)
                        }
                        .clipShape(.capsule)
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .transition(.opacity)
                        .onTapGesture {
                            do {
                                try context.save()
                                print("context saved with end of game")
                            } catch {
                                print("failed to save context at end of game")
                            }
                        }
                        
                    } else {
                        
                        // first tap: arm the confirmation in place
                        Button {
                            withAnimation {
                                confirmingFinish = true
                            }
                        } label: {
                            Text("Finish")
                                .padding(10)
                                .foregroundStyle(Color.blue)
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                        .transition(.opacity)
                    }
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: 350)
            
            // un-arm the confirmation if it goes unanswered
            .task(id: confirmingFinish) {
                guard confirmingFinish else { return }
                try? await Task.sleep(for: .seconds(4))
                guard !Task.isCancelled else { return }
                withAnimation {
                    confirmingFinish = false
                }
            }
            
            // back out of the confirmation on the way to the finished game, so
            // the button reads "Finish" again if the game is re-opened
            .onDisappear {
                confirmingFinish = false
            }
                
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
                NewPlayerSheet(
                    game: game,
                    newPlayerSheetShowing: $newPlayerSheetShowing,
                    useContext: .midGame
                )
                .presentationDetents([.medium, .large])
            }
            
            // edit game sheet
            .sheet(isPresented: $editGameSheetShowing) {
                EditGameSheet(
                    game: game,
                    gameName: $gameName,
                    lowestWins: $lowestWins,
                    halving: $halving,
                    editGameSheetShowing: $editGameSheetShowing,
                    markPracticeRounds: $markPracticeRounds
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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
        
    let previewGame = Game(
        players: [
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
        name: "Yaniv",
        halving: true,
        roundsPlayed: 17
    )
        
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Game.self, Player.self, configurations: config)
    container.mainContext.insert(previewGame)
    
    return NavigationStack {
        GameView(
            id: previewGame.id
        )
            .modelContainer(container)
            .environmentObject(ViewModel())
    }
}
