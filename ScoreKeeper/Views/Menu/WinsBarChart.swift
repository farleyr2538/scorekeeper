//
//  OverallLeaderboard.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 28/01/2026.
//

import SwiftUI
import SwiftData

struct WinsBarChart: View {
    
    @EnvironmentObject var viewModel : ViewModel
    
    @Query var games : [Game]
    
    @State var gameName : String = "All Games"
    @State var showPlayersWithoutWins : Bool = false
    
    var body: some View {
        
        let summary = games.winsSummary(gameName: gameName)
        let allPlayers = summary.players
        let data = showPlayersWithoutWins ? allPlayers : allPlayers.filter { $0.wins > 0 }
        let gamesPlayed = summary.gamesPlayed
        let draws = summary.draws
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 28) {
                
                // game filter
                Menu {
                    Picker("Game", selection: $gameName) {
                        Text("All Games").tag("All Games")
                        ForEach(viewModel.gameNames.sorted(), id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(gameName)
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                    }
                    .font(.headline)
                }
                
                // headline number
                VStack(alignment: .leading, spacing: 2) {
                    Text(gamesPlayed, format: .number)
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                    Text(gamesPlayed == 1 ? "game played" : "games played")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // wins per player, most wins first
                if data.isEmpty {
                    VStack(spacing: 4) {
                        Text(allPlayers.isEmpty ? "No games yet" : "No wins yet")
                            .foregroundStyle(.secondary)
                        if !allPlayers.isEmpty && draws > 0 {
                            Text(draws == 1 ? "1 draw" : "\(draws) draws")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                } else {
                    let mostWins = max(1, data.map(\.wins).max() ?? 0)
                    
                    VStack(spacing: 18) {
                        ForEach(data, id: \.name) { player in
                            VStack(spacing: 6) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(player.name)
                                    Spacer()
                                    Text(player.wins, format: .number)
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)
                                }
                                // bar length is relative to the player with the most wins
                                Capsule()
                                    .fill(Color.secondary.opacity(0.12))
                                    .frame(height: 8)
                                    .overlay(alignment: .leading) {
                                        GeometryReader { proxy in
                                            Capsule()
                                                .fill(Color.accentColor)
                                                .frame(width: proxy.size.width * CGFloat(player.wins) / CGFloat(mostWins))
                                        }
                                    }
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(player.name), \(player.wins) \(player.wins == 1 ? "win" : "wins")")
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Show players with no wins")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    // only this change animates (rows sliding in and out); changing
                    // the game swaps the list instantly, which keeps it responsive
                    Toggle("Show players with no wins", isOn: $showPlayersWithoutWins.animation(.snappy))
                        .labelsHidden()
                }
            }
            .padding(24)
        }
        .navigationTitle("Wins")
        
    }
    
}

extension Array where Element == Game {
    
    // wins per player, games played and draws for one game name (or "All Games"),
    // worked out in a single pass so each game's winners are only found once.
    // only games with at least two players and one round played are counted.
    func winsSummary(gameName: String) -> (players: [(name: String, wins: Int)], gamesPlayed: Int, draws: Int) {
        
        var wins : [String: Int] = [:]
        var gamesPlayed = 0
        var draws = 0
        
        for game in self {
            guard gameName == "All Games" || game.name == gameName else { continue }
            guard game.players.count > 1 && game.roundsPlayed > 0 else { continue }
            
            gamesPlayed += 1
            
            // everyone who played appears, even without a win
            for player in game.players {
                wins[player.name, default: 0] += 0
            }
            
            // a shared top score is a draw, not a win
            let winners = game.winners
            if winners.count == 1 {
                wins[winners[0].name, default: 0] += 1
            } else {
                draws += 1
            }
        }
        
        // most wins first, ties in alphabetical order
        let players = wins
            .map { (name: $0.key, wins: $0.value) }
            .sorted { $0.wins != $1.wins ? $0.wins > $1.wins : $0.name < $1.name }
        
        return (players, gamesPlayed, draws)
    }
}

#Preview {
    NavigationStack {
        WinsBarChart()
            .environmentObject(ViewModel())
            .modelContainer(for: [Game.self, Player.self], inMemory: true) { result in
                if case .success(let container) = result {
                    Game.sampleGames.forEach { game in
                        container.mainContext.insert(game)
                    }
                    
                }
            }
    }
}
