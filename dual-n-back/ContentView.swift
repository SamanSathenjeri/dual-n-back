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
    @StateObject private var homeViewModel = HomeViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel)
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
        .onChange(of: game.gameEnded) { _, gameEnded in
            if gameEnded {
                // Game just ended - increment round count
                homeViewModel.playRound()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Check for daily reset when app becomes active
                homeViewModel.checkDailyReset()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
