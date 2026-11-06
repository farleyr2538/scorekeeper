//
//  GameNameView.swift
//  ScoreKeeper
//
//  Created by Robert Farley on 22/12/2025.
//

import SwiftUI
import SwiftData

struct GameNameView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    
    @Binding var gameName : String
    
    @State private var isExpanded : Bool = false
    
    @FocusState private var isFocussed : Bool
    
    @Query private var games : [Game]
    
    // game names, most-played first. sorted once (and again if the games or names
    // change) rather than on every keystroke in the name field
    @State private var pickerOptions : [String] = []
    
    // most-played games first (counted from saved games), ties in alphabetical order
    func sortedGameNames() -> [String] {
        var timesPlayed : [String: Int] = [:]
        for game in games {
            if let name = game.name {
                timesPlayed[name, default: 0] += 1
            }
        }
        return viewModel.gameNames.sorted { name1, name2 in
            let count1 = timesPlayed[name1] ?? 0
            let count2 = timesPlayed[name2] ?? 0
            if count1 != count2 {
                return count1 > count2
            }
            return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
        }
    }
    
    var filteredOptions : [String] {
         if gameName.isEmpty {
             return pickerOptions
        } else {
            return pickerOptions.filter { $0.localizedCaseInsensitiveContains(gameName) }
        }
    }
    
    var proxy : ScrollViewProxy
    
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
                        .background(Color.darkAndLight)
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
                .id("gameNameTextField")
                .padding(.bottom, isExpanded ? 5 : 0)
                
                if isExpanded {
                    ForEach(filteredOptions.indices, id: \.self) { index in
                        let option = filteredOptions[index]
                        
                        Text(option)
                            .font(.system(size: 16.0))
                        
                            // internal
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                        
                            // background
                            .containerShape(.capsule)
                            .background(Color.yellow)
                            .cornerRadius(15)
                            .foregroundStyle(Color.black)
                        
                            // external
                            .padding(.bottom, 2)
                        
                            .onTapGesture {
                                
                                gameName = option
                                isFocussed = false
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                    withAnimation {
                                        isExpanded = false
                                    }
                                }
                                
                            }
                    }
                    .padding(.horizontal, 10)
                }
            }
            .padding(.bottom, isExpanded ? 5 : 0)
            // same colour as the text field, so the options read as its drop-down
            .background(Color.darkAndLight)
            .clipShape(RoundedRectangle(cornerRadius: 15.0))
            
        }
        .onAppear {
            pickerOptions = sortedGameNames()
        }
        .onChange(of: games.count) {
            pickerOptions = sortedGameNames()
        }
        .onChange(of: viewModel.gameNames) {
            pickerOptions = sortedGameNames()
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    
                    withAnimation {
                        proxy.scrollTo("gameNameTextField", anchor: .center)
                        isExpanded = true
                    }
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
    ScrollViewReader { proxy in
        GameNameView(
            gameName: .constant(""),
            proxy: proxy
        )
    }
        .environmentObject(ViewModel())
        .modelContainer(for: [Game.self, Player.self], inMemory: true) { result in
            if case .success(let container) = result {
                Game.sampleGames.forEach { game in
                    container.mainContext.insert(game)
                }
            }
        }
}
