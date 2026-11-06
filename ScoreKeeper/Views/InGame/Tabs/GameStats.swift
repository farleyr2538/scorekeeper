//
//  GameStats.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 06/11/2026.
//

import SwiftUI

struct GameStats: View {

    @Bindable var game : Game

    // when shown within another scrolling screen (the finished game), leave
    // out this view's own scroll view and outer padding
    var embedded : Bool = false

    // per-player figures for the current game
    struct PlayerStats {
        let id : UUID
        let name : String
        let averageRaw : Double?        // mean of the scores entered each round
        let averageWithHalving : Double? // net change in total per round, after halves
        let zeros : Int
        let halves : Int
        let pointsHalvedOff : Double
        let best : Double?
        let worst : Double?
    }

    func stats(for player: Player) -> PlayerStats {
        // the scores actually played, leaving out an averaged-in starting score,
        // which would otherwise skew every figure for a player who joined late
        let startingIndex = player.startingScoreRoundIndex
        let allRounds = player.filteredScores
        let rounds = allRounds.enumerated()
            .filter { $0.offset != startingIndex }
            .map(\.element)
        let startingScore = startingIndex.flatMap { allRounds.indices.contains($0) ? allRounds[$0] : nil } ?? 0

        let averageRaw = rounds.isEmpty ? nil : rounds.reduce(0, +) / Double(rounds.count)
        let averageWithHalving = rounds.isEmpty ? nil : (player.total - startingScore) / Double(rounds.count)

        return PlayerStats(
            id: player.id,
            name: player.name,
            averageRaw: averageRaw,
            averageWithHalving: averageWithHalving,
            zeros: rounds.count(where: { $0 == 0 }),
            // halves are stored as negative entries in scores
            halves: player.scores.count(where: { $0 < 0 }),
            pointsHalvedOff: player.scores.filter { $0 < 0 }.reduce(0) { $0 - $1 },
            best: game.lowestWins ? rounds.min() : rounds.max(),
            worst: game.lowestWins ? rounds.max() : rounds.min()
        )
    }

    func format(_ value: Double?) -> String {
        guard let value else { return "–" }
        return value.formatted(.number.precision(.fractionLength(0...1)))
    }

    var body: some View {
        if embedded {
            statsCards
        } else {
            ScrollView {
                statsCards
                    .frame(maxWidth: 450)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }
        }
    }

    private var statsCards : some View {

        let allStats = game.players.map { stats(for: $0) }
        let hasRounds = allStats.contains { $0.averageRaw != nil }

        return VStack(alignment: .leading, spacing: 24) {

                if !hasRounds {
                    Text("Stats will appear after the first round")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 120)
                } else {

                    Text(game.roundsPlayed == 1 ? "1 round played" : "\(game.roundsPlayed) rounds played")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)

                    // averages
                    StatsCard(title: "Average per round") {
                        Grid(alignment: .trailing, horizontalSpacing: 16, verticalSpacing: 10) {
                            GridRow {
                                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                                ColumnHeader(game.halving ? "Scored" : "Average")
                                if game.halving {
                                    ColumnHeader("After halving")
                                }
                            }
                            ForEach(allStats, id: \.id) { stat in
                                GridRow {
                                    Text(stat.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .gridColumnAlignment(.leading)
                                    Text(format(stat.averageRaw))
                                    if game.halving {
                                        Text(format(stat.averageWithHalving))
                                    }
                                }
                            }
                        }
                    }

                    // round-by-round highlights
                    StatsCard(title: "Rounds") {
                        Grid(alignment: .trailing, horizontalSpacing: 16, verticalSpacing: 10) {
                            GridRow {
                                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                                ColumnHeader("On 0")
                                if game.halving {
                                    ColumnHeader("Halves")
                                    ColumnHeader("Saved")
                                }
                                // with lowest-wins the best round is almost always 0, which "On 0" covers
                                if !game.lowestWins {
                                    ColumnHeader("Best")
                                }
                                ColumnHeader("Worst")
                            }
                            ForEach(allStats, id: \.id) { stat in
                                GridRow {
                                    Text(stat.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .gridColumnAlignment(.leading)
                                    Text(stat.zeros, format: .number)
                                    if game.halving {
                                        Text(stat.halves, format: .number)
                                        Text(format(stat.pointsHalvedOff))
                                    }
                                    if !game.lowestWins {
                                        Text(format(stat.best))
                                    }
                                    Text(format(stat.worst))
                                }
                            }
                        }
                    }
                }
            }
            .monospacedDigit()
    }
}

// a titled card, styled to match the leaderboard
private struct StatsCard<Content: View>: View {

    let title : String
    @ViewBuilder let content : Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            content
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

private struct ColumnHeader: View {

    let text : String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    GameStats(game: Game.sampleGames.first!)
}
