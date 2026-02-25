//
//  ContentView.swift
//  ZoomToImage
//
//  Created by Ali zaenal on 07/02/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    /// The game scene — @State keeps it alive across view updates.
    /// Because GameScene is @Observable, SwiftUI automatically
    /// re-evaluates the body when observable properties change.
    @State private var scene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .black
        scene.hotspots = [
            ImageHotspot(
                id: "part1",
                normalizedX: 0.3,
                normalizedY: 0.7,
                normalizedRadius: 0.06
            ),
            ImageHotspot(
                id: "part2",
                normalizedX: 0.7,
                normalizedY: 0.4,
                normalizedRadius: 0.08
            )
        ]
        return scene
    }()
    
    /// Shows the welcome page only once at the start
    @State private var showWelcome = true
    
    /// Controls which scene is shown: true = investigation, false = conversation
    @State private var isInvestigating = true
    
    var body: some View {
        ZStack {
            if showWelcome {
                // Welcome page - shown once at the start
                WelcomeView(onStartGame: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showWelcome = false
                    }
                })
                .transition(.opacity)
            } else if isInvestigating {
                // Investigation scene
                VStack(spacing: 0) {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                    
                    // Bottom menu bar
                    MenuBar(
                        isMagnifierEnabled: Binding(
                            get: { scene.isMagnifierEnabled },
                            set: { scene.isMagnifierEnabled = $0 }
                        ),
                        onCluePressed: {
                            scene.showClue()
                        }
                    )
                }
                .onChange(of: scene.allHotspotsFound) { _, found in
                    if found {
                        print("[ContentView] All hotspots found! Switching to conversation.")
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isInvestigating = false
                        }
                    }
                }
                .transition(.opacity)
            } else {
                // Conversation scene
                ConversationView(onConversationEnd: {
                    print("[ContentView] Conversation ended. Returning to investigation.")
                    // Create a fresh scene for the next round
                    let newScene = GameScene()
                    newScene.scaleMode = .resizeFill
                    newScene.backgroundColor = .black
                    newScene.hotspots = scene.hotspots
                    scene = newScene
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isInvestigating = true
                    }
                })
                .transition(.opacity)
            }
        }
        .background(.black)
    }
}

struct MenuBar: View {
    @Binding var isMagnifierEnabled: Bool
    var onCluePressed: () -> Void
    
    var body: some View {
        HStack(spacing: 32) {
            // Magnifier toggle button
            Button {
                isMagnifierEnabled.toggle()
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: isMagnifierEnabled ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                        .font(.system(size: 28))
                    
                    Text("Magnifier")
                        .font(.caption)
                }
                .foregroundStyle(isMagnifierEnabled ? .blue : .white)
            }
            
            Spacer()
            
            // Clue button
            Button {
                onCluePressed()
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "lightbulb.circle")
                        .font(.system(size: 28))
                    
                    Text("Clue")
                        .font(.caption)
                }
                .foregroundStyle(.yellow)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    ContentView()
}
