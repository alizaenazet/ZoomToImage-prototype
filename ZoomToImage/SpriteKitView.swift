//
//  SpriteKitView.swift
//  ZoomToImage
//
//  Created by AI Assistant on 07/02/26.
//

import SwiftUI
import SpriteKit

struct SpriteKitView: UIViewRepresentable {
    @Binding var isMagnifierEnabled: Bool
    let hotspots: [ImageHotspot]
    var onShowClue: ((@escaping () -> Void) -> Void)?
    var onAllHotspotsFound: (() -> Void)?
    var onResetHotspots: ((@escaping () -> Void) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.backgroundColor = .black
        
        // Create scene with hotspots
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .black
        scene.hotspots = hotspots
        skView.presentScene(scene)
        
        // Store reference to scene in coordinator
        context.coordinator.gameScene = scene
        print("[SpriteKitView] makeUIView - scene created, hotspots count: \(hotspots.count)")
        
        // Wire up the all-hotspots-found callback
        let allFoundCallback = onAllHotspotsFound
        scene.onAllHotspotsFound = {
            print("[SpriteKitView] All hotspots found, notifying ContentView")
            allFoundCallback?()
        }
        
        // Provide the clue trigger closure
        let coordinator = context.coordinator
        let clueCallback = onShowClue
        let resetCallback = onResetHotspots
        DispatchQueue.main.async {
            clueCallback? {
                coordinator.gameScene?.showClue()
            }
            resetCallback? {
                coordinator.gameScene?.resetHotspots()
            }
        }
        
        return skView
    }
    
    func updateUIView(_ skView: SKView, context: Context) {
        // Update magnifier state
        if let gameScene = skView.scene as? GameScene {
            gameScene.isMagnifierEnabled = isMagnifierEnabled
        }
    }
    
    class Coordinator {
        var gameScene: GameScene?
    }
}
