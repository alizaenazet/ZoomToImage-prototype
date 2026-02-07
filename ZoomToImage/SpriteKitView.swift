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
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.backgroundColor = .black
        
        // Create scene with a default size - it will resize automatically
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .black
        skView.presentScene(scene)
        
        return skView
    }
    
    func updateUIView(_ skView: SKView, context: Context) {
        // Update magnifier state
        if let gameScene = skView.scene as? GameScene {
            gameScene.isMagnifierEnabled = isMagnifierEnabled
        }
    }
}
