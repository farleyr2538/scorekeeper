//
//  ContentView.swift
//  Yanev
//
//  Created by Robert Farley on 22/06/2025.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel : ViewModel
    
    @State var createGameButtonPressed : Bool = false
        
    var yOffset : CGFloat = 70.0
    
    var body: some View {
        NavigationStack {
            
            Spacer()
                
            HStack {
                ZStack(alignment: .leading) {
                    Text("Score")
                        .offset(y: 0 - yOffset)
                    Text("Keeper")
                    
                }
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(.gray)
                .padding()
                
                Spacer()
            }
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        GameHistory()
                    } label: {
                        Image(systemName: "clock")
                    }
                }
            }
            
            Spacer()
            
            NavigationLink {
                CreateGameView()
            } label: {
                FullWidthButton(text: "Create Game")
                    .padding(.horizontal)
            }
            .scaleEffect(createGameButtonPressed ? 0.9 : 1.0)
            .animation(.spring(), value: createGameButtonPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0.0)
                    .onChanged { _ in createGameButtonPressed = true }
                    .onEnded { _ in createGameButtonPressed = false }
            )
        }
        
    }
}

#Preview {
    ContentView()
        .environmentObject(ViewModel())
}
