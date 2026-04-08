//
//  SelectableOption.swift
//  ScoreKeeper
//
//  Created by Rob Farley on 07/04/2026.
//

import SwiftUI

struct SelectableOption: View {
    
    var text : String
    var score : Double?
    var selected : Bool
    
    var body: some View {
        
        HStack {
            
            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .imageScale(Image.Scale.large)
                .foregroundStyle(selected ? .blue : .gray)
                .opacity(selected ? 1.0 : 0.4)
            
            Text(text)
            
            if let unwrappedScore = score {
                Text("(" + String(unwrappedScore) + ")")
                    .foregroundStyle(.gray)
            }
            
        }
        
    }
}

#Preview {
    SelectableOption(text: "Average Score", score: 5, selected: true)
}
