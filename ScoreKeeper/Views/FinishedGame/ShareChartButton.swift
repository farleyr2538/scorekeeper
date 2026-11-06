//
//  ShareChartButton.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 23/09/2026.
//

import SwiftUI

// A share button for a game's progress chart. The chart is rendered to an
// image - with the game's title and date above it, so it stands on its own in
// a message - and handed to the system share sheet. A finished game also
// carries its winner; an in-progress one doesn't.
struct ShareChartButton: View {
    
    @EnvironmentObject var viewModel : ViewModel
    
    @Environment(\.displayScale) var displayScale
    
    var game : Game
    
    // shared mid-game, the image shouldn't claim anyone has won yet
    var inProgress : Bool = false
    
    @State var chartImage : Image? = nil
    
    var body: some View {
        
        Group {
            if let chartImage {
                ShareLink(
                    item: chartImage,
                    preview: SharePreview(shareTitle, image: chartImage)
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            } else {
                // inert stand-in, so the layout doesn't jump when the render lands
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.gray)
            }
        }
        .task(id: game.roundsPlayed) {
            renderChart()
        }
    }
    
    var shareTitle : String {
        let gameName = game.name ?? ""
        return gameName.isEmpty ? "Game chart" : "\(gameName) chart"
    }
    
    // what actually gets sent: the chart, plus enough context to make sense of it
    var shareableChart : some View {
        VStack(alignment: .leading, spacing: 5) {
            
            HistoricGameTitle(game: game, inProgress: inProgress)
                // the renderer draws a detached view, so it needs the view model
                // handing to it explicitly
                .environmentObject(viewModel)
            
            // not interactive: the renderer can't draw the press-and-hold layer
            ScoreChart(game: game, isInteractive: false)
                .padding(.top, 10)
        }
        .padding(20)
        .frame(width: 450)
        // a fixed light background, so the image is legible wherever it lands
        .background(Color.white)
        .environment(\.colorScheme, .light)
    }
    
    @MainActor
    func renderChart() {
        let renderer = ImageRenderer(content: shareableChart)
        renderer.scale = displayScale
        
        if let uiImage = renderer.uiImage {
            chartImage = Image(uiImage: uiImage)
        }
    }
}

#Preview {
    ShareChartButton(game: Game.sampleGames.first!)
        .environmentObject(ViewModel())
}
