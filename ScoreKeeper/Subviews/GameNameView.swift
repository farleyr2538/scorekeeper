//
//  GameNameView.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 22/12/2025.
//

import SwiftUI

struct GameNameView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var gameName : String
    
    @State private var isExpanded : Bool = false
    
    @FocusState private var isFocussed : Bool
    
    var pickerOptions : [String] { viewModel.gameNames }
    
    var filteredOptions : [String] {
        
         if gameName.isEmpty {
             return []
        } else {
            return pickerOptions.filter { $0.localizedCaseInsensitiveContains(gameName) }
        }
    }
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text("Game Name")
                .font(.title3.bold())
            
            VStack(alignment: .leading, spacing: 4) {
                ZStack {
                    TextField("Optional (eg. 'Yaniv')", text: $gameName)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
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
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.down.circle" : "chevron.backward.circle")
                            .foregroundStyle(.gray)
                            .onTapGesture {
                                withAnimation(.default) {
                                    isExpanded.toggle()
                                }
                            }
                            .padding(.trailing, 5)
                    }
                    
                }
                .padding(.bottom, isExpanded ? 5 : 0)
                
                if isExpanded {
                    ForEach(filteredOptions.indices, id: \.self) { index in
                        let option = filteredOptions[index]
                        Text(option)
                            .font(.system(size: 16.0))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .containerShape(.capsule)
                            .background(Color.yellow)
                            .cornerRadius(15)
                            .foregroundStyle(Color.black)
                            .onTapGesture {
                                
                                gameName = option
                                isFocussed = false
                                isExpanded = false
                                
                                /*
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation {
                                        isExpanded = false
                                    }
                                }
                                */
                            }
                    }
                    .padding(.horizontal, 10)
                }
            }
            .padding(.bottom, isExpanded ? 5 : 0)
            .background(.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 15.0))
            
        }
        .onChange(of: gameName) {
            if filteredOptions.isEmpty {
                withAnimation {
                    isExpanded = false
                }
            } else {
                withAnimation {
                    isExpanded = true
                }
            }
        }
        .onChange(of: isFocussed) {
            if isFocussed {
                withAnimation {
                    isExpanded = true
                }
            } else {
                withAnimation {
                    isExpanded = false
                }
            }
        }
    }
}

#Preview {
    GameNameView(gameName: .constant(""))
        .environmentObject(ViewModel())
        .modelContainer(for: [Game.self, Player.self], inMemory: true) { result in
            if case .success(let container) = result {
                Game.sampleGames.forEach { game in
                    container.mainContext.insert(game)
                }
            }
        }
}
