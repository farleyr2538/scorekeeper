//
//  Chart.swift
//  Yanev
//
//  Created by Robert Farley on 29/06/2025.
//

import SwiftUI
import Charts

struct ScoreChart: View {
    
    @Bindable var game : Game

    // whether press-and-hold shows tooltips. Off when the chart is rendered to
    // an image for sharing, which can't draw the UIKit view the gesture uses.
    var isInteractive : Bool = true

    // the player being followed and the round shown in the tooltip, if any
    @State private var selectedPlayerID : UUID? = nil
    @State private var selectedRound : Int? = nil

    // everyone drawn on the same spot as the followed player at that round,
    // including them, so the tooltip can list them all
    @State private var playersOnSelectedSpot : [UUID] = []

    // how close two points can be drawn before they count as the same spot
    static let sameSpotDistance : CGFloat = 8

    // how much closer the finger must be to another line before the tooltip
    // switches to it
    static let switchLineMargin : CGFloat = 12

    // plays the tooltip's haptics; only sets the Taptic Engine up on first use
    @State private var haptics = ChartHaptics()

    var body: some View {

        // read up front, so the chart's dependency on every player's
        // runningScores is tracked by this body
        let points = chartPoints

        let selectedPoint = points.first {
            $0.playerID == selectedPlayerID && $0.round == selectedRound
        }

        // everyone on that spot, highest first, to match the order they're drawn in
        let pointsOnSelectedSpot = points
            .filter { playersOnSelectedSpot.contains($0.playerID) && $0.round == selectedRound }
            .sorted { $0.score > $1.score }

        LazyVStack {

            Group {
                if game.roundsPlayed < 2 {
                    HStack {
                        Spacer()
                        Text("Not enough rounds for a chart")
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                } else {

                    Chart {
                        ForEach(points) { point in
                            LineMark(
                                x: .value("Round", point.round),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(by: .value("Player", point.playerName))
                            .symbol(by: .value("Player", point.playerName))
                        }

                        if let selectedPoint {
                            selectionMarks(selectedPoint: selectedPoint, pointsOnSpot: pointsOnSelectedSpot)
                        }
                    }
                    // a light tap when the tooltip opens, and a tick each time it
                    // moves to another round or player; nothing when it closes
                    .onChange(of: selectionKey) { oldKey, newKey in
                        guard newKey != nil else { return }
                        if oldKey == nil {
                            haptics.tooltipOpened()
                        } else {
                            haptics.tooltipMoved()
                        }
                    }
                    // press and hold on a line to show that player's score, then
                    // drag sideways to move between rounds, or up and down to
                    // switch players; it hides when the finger lifts
                    .chartOverlay { proxy in
                        if isInteractive {
                            GeometryReader { geometry in
                                HoldAndDragArea(haptics: haptics) { location in
                                    updateSelection(at: location, proxy: proxy, geometry: geometry)
                                } onChanged: { location in
                                    updateSelection(at: location, proxy: proxy, geometry: geometry)
                                } onEnded: {
                                    selectedPlayerID = nil
                                    selectedRound = nil
                                    playersOnSelectedSpot = []
                                }
                            }
                        }
                    }
                    // each player's symbol and colour, fixed so the highlighted
                    // point and the tooltip can match them
                    .chartSymbolScale(
                        domain: game.players.map(\.name),
                        range: game.players.map { symbol(for: $0.name) }
                    )
                    .chartForegroundStyleScale(
                        domain: game.players.map(\.name),
                        range: game.players.map { color(for: $0.name) }
                    )
                    // a little padding inside the plot, so the labels for the
                    // first and latest rounds have room and aren't dropped
                    .chartXScale(domain: 0...latestRound, range: .plotDimension(padding: 12))
                    // headroom above the highest point, so its tooltip still has
                    // room to sit clear of the finger without leaving the chart
                    .chartYScale(range: .plotDimension(endPadding: 24))
                    .chartXAxis {
                        AxisMarks(values: xAxisRounds) {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .frame(maxWidth: 450)
                }
            }
            .frame(height: 300)
            .padding(.horizontal, 15)
            
        }

    }

    // Every player's running total, starting from 0 before the first round.
    // This is built in body (rather than inside the Chart's ForEach closures,
    // which Swift Charts evaluates lazily) so that SwiftUI tracks each
    // player's runningScores and redraws the chart when a round is added.
    var chartPoints: [ChartPoint] {
        game.players.flatMap { player in
            ([0] + player.runningScores).enumerated().map { round, score in
                ChartPoint(playerID: player.id, playerName: player.name, round: round, score: score)
            }
        }
    }

    // Swift Charts' own symbol order, one per player (a game has at most eight)
    static let symbols: [BasicChartSymbolShape] = [
        .circle, .square, .triangle, .diamond, .pentagon, .cross, .plus, .asterisk
    ]

    // each player's colour, in the same order Swift Charts would pick them,
    // fixed so the tooltip can show it
    static let colors: [Color] = [
        .blue, .green, .orange, .purple, .red, .cyan, .yellow, .pink
    ]

    func playerIndex(for playerName: String) -> Int {
        game.players.firstIndex { $0.name == playerName } ?? 0
    }

    func symbol(for playerName: String) -> BasicChartSymbolShape {
        Self.symbols[playerIndex(for: playerName) % Self.symbols.count]
    }

    func color(for playerName: String) -> Color {
        Self.colors[playerIndex(for: playerName) % Self.colors.count]
    }

    // the round nearest the finger
    func round(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> Int? {
        guard let plotFrame = proxy.plotFrame else { return nil }
        let xInPlot = location.x - geometry[plotFrame].origin.x
        guard let value = proxy.value(atX: xInPlot, as: Double.self) else { return nil }

        return min(max(Int(value.rounded()), 0), latestRound)
    }

    // Show the round nearest the finger, on the line closest to it there.
    // Once a player is being followed, only switch to another line when the
    // finger is clearly closer to it, so the tooltip doesn't flicker between
    // players where lines cross or run close together.
    func updateSelection(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame,
              let round = round(at: location, proxy: proxy, geometry: geometry) else { return }
        let yInPlot = location.y - geometry[plotFrame].origin.y

        let pointsThisRound = chartPoints.filter { $0.round == round }
        let nearest = pointsThisRound.min { first, second in
            distance(from: yInPlot, to: first, proxy: proxy) < distance(from: yInPlot, to: second, proxy: proxy)
        }

        if let followed = pointsThisRound.first(where: { $0.playerID == selectedPlayerID }),
           let nearest,
           distance(from: yInPlot, to: followed, proxy: proxy) - distance(from: yInPlot, to: nearest, proxy: proxy) < Self.switchLineMargin {
            // stay on the current line
        } else {
            selectedPlayerID = nearest?.playerID
        }

        select(round: round, proxy: proxy)
    }

    // Move the tooltip to a round on the followed player's line, and work out
    // who else is drawn on the same spot there.
    func select(round: Int, proxy: ChartProxy) {
        selectedRound = round

        let pointsThisRound = chartPoints.filter { $0.round == round }
        guard let followed = pointsThisRound.first(where: { $0.playerID == selectedPlayerID }),
              let followedY = proxy.position(forY: followed.score) else {
            playersOnSelectedSpot = []
            return
        }

        playersOnSelectedSpot = pointsThisRound
            .filter { distance(from: followedY, to: $0, proxy: proxy) <= Self.sameSpotDistance }
            .map(\.playerID)
    }

    // identifies the tooltip's current player and round, so haptics can tell
    // when it opens or moves
    var selectionKey: String? {
        guard let selectedPlayerID, let selectedRound else { return nil }
        return "\(selectedPlayerID)-\(selectedRound)"
    }

    // how far a point is drawn from a height on the plot, vertically
    func distance(from yInPlot: CGFloat, to point: ChartPoint, proxy: ChartProxy) -> CGFloat {
        guard let pointY = proxy.position(forY: point.score) else { return .infinity }
        return abs(pointY - yInPlot)
    }

    // The tooltip: everyone on the held spot enlarged in their colour, with the
    // score of each of them above the followed player's point.
    @ChartContentBuilder
    func selectionMarks(selectedPoint: ChartPoint, pointsOnSpot: [ChartPoint]) -> some ChartContent {

        // anyone else sharing the spot
        ForEach(pointsOnSpot.filter { $0.playerID != selectedPoint.playerID }) { point in
            highlightedMark(for: point)
        }

        highlightedMark(for: selectedPoint)
            // above the point; kept inside the plot's width so it never
            // covers the y-axis labels, and allowed above the plot so it
            // never slides down over the point itself
            .annotation(
                position: .top,
                // high enough to clear the finger holding the point
                spacing: 20,
                overflowResolution: .init(x: .fit(to: .plot), y: .disabled)
            ) {
                tooltip(for: pointsOnSpot.isEmpty ? [selectedPoint] : pointsOnSpot)
            }
    }

    // a player's point, enlarged
    func highlightedMark(for point: ChartPoint) -> some ChartContent {
        PointMark(
            x: .value("Round", point.round),
            y: .value("Score", point.score)
        )
        .foregroundStyle(by: .value("Player", point.playerName))
        // set directly: mapping by value here gives some players the wrong shape
        .symbol(symbol(for: point.playerName))
        .symbolSize(150)
    }

    // one "{name}: {score}" line per player on the held spot
    func tooltip(for points: [ChartPoint]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(points) { point in
                HStack(spacing: 4) {
                    Circle()
                        .fill(color(for: point.playerName))
                        .frame(width: 8, height: 8)
                    Text("\(point.playerName): \(point.score.formatted())")
                }
            }
        }
        .font(.caption)
        .monospacedDigit()
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        // solid, so the chart's lines don't show through behind the text
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.3)))
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }

    var latestRound: Int {
        game.players.map(\.runningScores.count).max() ?? 0
    }

    // The rounds to label on the x-axis: every round in short games, thinning
    // out to roughly eight labels in long ones. The latest round is always
    // labelled, so it's clear how far the game has got.
    var xAxisRounds: [Int] {
        let step = max(1, Int((Double(latestRound) / 8).rounded(.up)))
        var rounds = Array(stride(from: 0, to: latestRound, by: step))

        // drop the label before the latest round if the two would crowd together
        if let previous = rounds.last, previous > 0, latestRound - previous < step / 2 {
            rounds.removeLast()
        }

        rounds.append(latestRound)
        return rounds
    }

}

// A transparent area that recognises a press-and-hold, then keeps reporting
// the finger's position as it drags. This uses UIKit's long press rather than
// SwiftUI gestures because SwiftUI's version stops the page view from seeing
// quick swipes, and doesn't report a position until the finger moves. UIKit's
// leaves the touch alone until the hold is recognised (so a quick swipe still
// turns the page), then takes it over (so the drag moves the tooltip instead).
struct HoldAndDragArea: UIViewRepresentable {

    // given this area's view, which UIKit's feedback generators need
    var haptics: ChartHaptics

    // the finger's location, in this view's coordinate space: first when the
    // hold is recognised, then each time it moves
    var onBegan: (CGPoint) -> Void
    var onChanged: (CGPoint) -> Void
    // the finger lifted, or the system cancelled the touch
    var onEnded: () -> Void

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        haptics.view = view

        let recognizer = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handle(_:))
        )
        recognizer.minimumPressDuration = 0.3
        view.addGestureRecognizer(recognizer)

        return view
    }

    func updateUIView(_ view: UIView, context: UIViewRepresentableContext<Self>) {
        // keep the coordinator calling the latest closures
        context.coordinator.parent = self
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor
    final class Coordinator: NSObject {
        var parent: HoldAndDragArea

        init(parent: HoldAndDragArea) {
            self.parent = parent
        }

        @objc func handle(_ recognizer: UILongPressGestureRecognizer) {
            switch recognizer.state {
            case .began:
                parent.onBegan(recognizer.location(in: recognizer.view))
            case .changed:
                parent.onChanged(recognizer.location(in: recognizer.view))
            default:
                parent.onEnded()
            }
        }
    }
}

// The tooltip's haptics. The feedback generators are only created the first
// time the tooltip opens: creating them sets up the Taptic Engine, which is
// slow the first time after launch. SwiftUI's sensoryFeedback does that as
// soon as the chart is built - which happens in advance, mid-swipe, as the
// game's pages are swiped - so it made the swipe stutter.
@MainActor
final class ChartHaptics {

    // the view the feedback is played from, set by HoldAndDragArea
    weak var view: UIView?

    private var openFeedback: UIImpactFeedbackGenerator?
    private var moveFeedback: UISelectionFeedbackGenerator?

    // a light tap when the tooltip opens
    func tooltipOpened() {
        guard let view else { return }
        if openFeedback == nil {
            openFeedback = UIImpactFeedbackGenerator(style: .light, view: view)
        }
        openFeedback?.impactOccurred()

        // the tooltip is likely to move next, so get that feedback ready
        if moveFeedback == nil {
            moveFeedback = UISelectionFeedbackGenerator(view: view)
        }
        moveFeedback?.prepare()
    }

    // a tick each time it moves to another round or player
    func tooltipMoved() {
        moveFeedback?.selectionChanged()
        moveFeedback?.prepare()
    }
}

// a single point on the chart: one player's running total after a given round
struct ChartPoint: Identifiable {
    let playerID: UUID
    let playerName: String
    let round: Int
    let score: Double

    var id: String { "\(playerID)-\(round)" }
}

#Preview {
    ScoreChart(
        game:
            Game(players: [
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
                halving: true,
                roundsPlayed: 17
            )
        
    )
    .modelContainer(for: Player.self, inMemory: true)
}
