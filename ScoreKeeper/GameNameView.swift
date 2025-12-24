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
        VStack {
            Text("Game Name")
                .font(.title3.bold())
            TextField("Optional", text: $gameName)
                .padding(10)
                .cornerRadius(10)
                .autocorrectionDisabled()
                .background(Color.white.opacity(0.5))
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
