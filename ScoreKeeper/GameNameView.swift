//
//  GameNameView.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 22/12/2025.
//

import SwiftUI

struct GameNameView: View {
    
    @Binding var gameName : String
    @FocusState private var isFocussed : Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Name")
                .font(.title3.bold())
            TextField("Optional", text: $gameName)
                
                .padding(10)
                .autocorrectionDisabled()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.05))
                        .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                )
                
                .focused($isFocussed)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isFocussed = false
                        }
                    }
                }
        }
    }
}

#Preview {
    GameNameView(gameName: .constant("Yaniv"))
}
