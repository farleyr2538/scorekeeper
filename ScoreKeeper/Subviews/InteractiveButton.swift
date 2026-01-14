//
//  InteractiveButton.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 22/10/2025.
//

import SwiftUI

struct InteractiveButton: View {
        
    @State var isTapped : Bool = false
    
    var body: some View {
        Button {
            print("isTapped")
        } label: {
            Text("Hello, World")
        }
        .scaleEffect(isTapped ? 0.8 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTapped)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0.0)
                .onChanged { _ in isTapped = true }
                .onEnded { _ in isTapped = false }
        )
        .buttonStyle(.borderedProminent)
    }
}

struct ScaleButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color(.systemBlue))
            .foregroundStyle(Color.white)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
    }
}

#Preview {
    InteractiveButton()
}
