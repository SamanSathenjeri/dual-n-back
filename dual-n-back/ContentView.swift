//
//  ContentView.swift
//  DualNBack
//
//  Main app view with tab navigation
//

import SwiftUI

struct ContentView: View {
    @StateObject private var game = DualNBackGame()
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        TabView {
            HomeView()
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            GameView(game: game)
            .tabItem {
                Image(systemName: "paperplane.fill")
                Text("Play")
            }
            
            SettingsView(game: game)
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
