//
//  PastGames.swift
//  Yanev
//
//  Created by Robert Farley on 24/06/2025.
//

import SwiftUI
import SwiftData

struct GameHistory: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var viewModel : ViewModel
    
    @Query(sort: \Game.date, order: .reverse) var pastGames : [Game]
    
    @State private var searchText : String = ""
    @State private var searchScope : SearchScope = .all
    
    enum SearchScope {
        case all     // game name or any player's name
        case winner  // only the winner's name (including joint winners)
    }
    
    // games matching the search, within the chosen scope
    var filteredGames : [Game] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return pastGames }
        return pastGames.filter { game in
            switch searchScope {
            case .all:
                return (game.name ?? "").localizedCaseInsensitiveContains(query)
                    || game.players.contains { $0.name.localizedCaseInsensitiveContains(query) }
            case .winner:
                // with no rounds played everyone is level on 0, so nobody has won
                guard game.roundsPlayed > 0 else { return false }
                return game.winners.contains { $0.name.localizedCaseInsensitiveContains(query) }
            }
        }
    }
        
    // offsets refer to the (possibly filtered) list being shown
    func deleteGames(at offsets : IndexSet, from shownGames : [Game]) {
        for offset in offsets {
            context.delete(shownGames[offset])
        }
    }
    
    var body: some View {
                
        Group {
            if pastGames.isEmpty {
                Text("No past games")
                    .foregroundStyle(Color.gray)
            } else {
                // filter once per update, and share the result with the list,
                // the empty state and deletion
                let shownGames = filteredGames
                
                // this screen is pushed onto the home screen's NavigationStack, so it
                // doesn't need its own: a nested stack makes the search bar fight
                // the outer navigation bar when it opens
                List {
                    ForEach(shownGames) { game in
                        
                        NavigationLink {
                            GameView(id: game.id)
                        } label: {
                            HistoricGameTitle(game: game)
                        }
                        
                    }
                    .onDelete { offsets in
                        deleteGames(at: offsets, from: shownGames)
                    }
                }
                .navigationTitle("Past Games")
                .searchable(text: $searchText, prompt: searchScope == .all ? "Game or player name" : "Winner's name")
                .searchScopes($searchScope) {
                    Text("All").tag(SearchScope.all)
                    Text("Winner").tag(SearchScope.winner)
                }
                .overlay {
                    if shownGames.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
            }
        }
        
        
    }
}

#Preview {
    NavigationStack {
        GameHistory()
    }
        .modelContainer(for: [Game.self, Player.self], inMemory: true) { result in
            if case .success(let container) = result {
                Game.sampleGames.forEach { game in
                    container.mainContext.insert(game)
                }
            }
        }
        .environmentObject(ViewModel())
}


