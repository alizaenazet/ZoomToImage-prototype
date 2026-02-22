//
//  GameScene.swift
//  ZoomToImage
//
//  Created by AI Assistant on 07/02/26.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Properties
    private var imageNode: SKSpriteNode?
    private var magnifierNode: SKNode?
    private var originalTexture: SKTexture!
    
    var isMagnifierEnabled: Bool = false {
        didSet {
            if !isMagnifierEnabled {
                magnifierNode?.removeFromParent()
                magnifierNode = nil
            }
        }
    }
    
    // Magnifier configuration
    private let magnifierRadius: CGFloat = 100
    private let zoomFactor: CGFloat = 3.0
    
    // MARK: - Hotspots
    
    /// Configurable hotspots - define clickable regions using normalized coordinates
    var hotspots: [ImageHotspot] = []
    
    /// Track which hotspots have been activated (marked)
    private var activatedHotspotIds: Set<String> = []
    
    /// Dictionary to store marker nodes by hotspot ID
    private var hotspotMarkers: [String: SKNode] = [:]
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        loadTexture()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        // Reconfigure image when scene size changes
        if size.width > 0 && size.height > 0 {
            setupImage()
            // Redraw any existing markers at new positions
            redrawHotspotMarkers()
        }
    }
    
    // MARK: - Setup
    
    private func loadTexture() {
        // Load the image texture once
        originalTexture = SKTexture(imageNamed: "ai-dummy-image")
    }
    
    private func setupImage() {
        guard originalTexture != nil else { return }
        
        // Remove existing image node if any
        imageNode?.removeFromParent()
        
        // Create the sprite node
        let node = SKSpriteNode(texture: originalTexture)
        
        // Calculate size for 9:16 aspect ratio fitting in the scene
        let targetAspectRatio: CGFloat = 9.0 / 16.0
        let sceneAspectRatio = size.width / size.height
        
        var imageWidth: CGFloat
        var imageHeight: CGFloat
        
        if sceneAspectRatio > targetAspectRatio {
            // Scene is wider, fit by height
            imageHeight = size.height
            imageWidth = imageHeight * targetAspectRatio
        } else {
            // Scene is taller, fit by width
            imageWidth = size.width
            imageHeight = imageWidth / targetAspectRatio
        }
        
        node.size = CGSize(width: imageWidth, height: imageHeight)
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        node.zPosition = 0
        
        addChild(node)
        imageNode = node
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if isMagnifierEnabled {
            updateMagnifier(at: location)
        } else {
            // Check for hotspot taps when magnifier is disabled
            checkHotspotTap(at: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isMagnifierEnabled, let touch = touches.first else { return }
        let location = touch.location(in: self)
        updateMagnifier(at: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        magnifierNode?.removeFromParent()
        magnifierNode = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        magnifierNode?.removeFromParent()
        magnifierNode = nil
    }
    
    // MARK: - Hotspot Detection
    
    private func checkHotspotTap(at position: CGPoint) {
        guard let imageNode = imageNode else { return }
        
        // Check if touch is within the image bounds
        guard imageNode.contains(position) else { return }
        
        // Convert scene position to normalized image coordinates
        let imageOriginX = imageNode.position.x - imageNode.size.width / 2
        let imageOriginY = imageNode.position.y - imageNode.size.height / 2
        
        let normalizedX = (position.x - imageOriginX) / imageNode.size.width
        let normalizedY = (position.y - imageOriginY) / imageNode.size.height
        
        // Check each hotspot
        for hotspot in hotspots {
            let dx = normalizedX - hotspot.normalizedX
            let dy = normalizedY - hotspot.normalizedY
            let distance = sqrt(dx * dx + dy * dy)
            
            // Check if tap is within hotspot radius
            if distance <= hotspot.normalizedRadius {
                activateHotspot(hotspot)
                break // Only activate one hotspot per tap
            }
        }
    }
    
    private func activateHotspot(_ hotspot: ImageHotspot) {
        // Toggle activation
        if activatedHotspotIds.contains(hotspot.id) {
            // Deactivate - remove marker
            activatedHotspotIds.remove(hotspot.id)
            hotspotMarkers[hotspot.id]?.removeFromParent()
            hotspotMarkers.removeValue(forKey: hotspot.id)
        } else {
            // Activate - add marker
            activatedHotspotIds.insert(hotspot.id)
            drawHotspotMarker(for: hotspot)
        }
    }
    
    private func drawHotspotMarker(for hotspot: ImageHotspot) {
        guard let imageNode = imageNode else { return }
        
        // Remove existing marker if any
        hotspotMarkers[hotspot.id]?.removeFromParent()
        
        // Calculate scene position from normalized coordinates
        let imageOriginX = imageNode.position.x - imageNode.size.width / 2
        let imageOriginY = imageNode.position.y - imageNode.size.height / 2
        
        let sceneX = imageOriginX + hotspot.normalizedX * imageNode.size.width
        let sceneY = imageOriginY + hotspot.normalizedY * imageNode.size.height
        
        // Calculate radius in scene coordinates
        let sceneRadius = hotspot.normalizedRadius * imageNode.size.width
        
        // Create marker circle (like pen marking)
        let marker = SKShapeNode(circleOfRadius: sceneRadius)
        marker.strokeColor = .red
        marker.lineWidth = 3
        marker.fillColor = UIColor.red.withAlphaComponent(0.2)
        marker.position = CGPoint(x: sceneX, y: sceneY)
        marker.zPosition = 50
        
        addChild(marker)
        hotspotMarkers[hotspot.id] = marker
    }
    
    private func redrawHotspotMarkers() {
        // Redraw all active markers at their new positions
        for hotspotId in activatedHotspotIds {
            if let hotspot = hotspots.first(where: { $0.id == hotspotId }) {
                drawHotspotMarker(for: hotspot)
            }
        }
    }
    
    // MARK: - Clue / Sonar Animation
    
    /// Shows a sonar pulse animation on a random unactivated hotspot
    func showClue() {
        print("[Clue] showClue() called")
        print("[Clue] Total hotspots: \(hotspots.count)")
        print("[Clue] Activated hotspot IDs: \(activatedHotspotIds)")
        
        // Get unactivated hotspots
        let unactivatedHotspots = hotspots.filter { !activatedHotspotIds.contains($0.id) }
        print("[Clue] Unactivated hotspots count: \(unactivatedHotspots.count)")
        
        // Return if no unactivated hotspots
        guard let randomHotspot = unactivatedHotspots.randomElement() else {
            print("[Clue] No unactivated hotspots available")
            return
        }
        
        guard let imageNode = imageNode else {
            print("[Clue] imageNode is nil")
            return
        }
        
        print("[Clue] Selected hotspot: \(randomHotspot.id)")
        print("[Clue] Image node size: \(imageNode.size), position: \(imageNode.position)")
        
        // Calculate scene position from normalized coordinates
        let imageOriginX = imageNode.position.x - imageNode.size.width / 2
        let imageOriginY = imageNode.position.y - imageNode.size.height / 2
        
        let sceneX = imageOriginX + randomHotspot.normalizedX * imageNode.size.width
        let sceneY = imageOriginY + randomHotspot.normalizedY * imageNode.size.height
        let position = CGPoint(x: sceneX, y: sceneY)
        
        print("[Clue] Sonar position: \(position)")
        
        // Create sonar pulse animation
        createSonarPulse(at: position)
    }
    
    private func createSonarPulse(at position: CGPoint) {
        print("[Clue] Creating sonar pulse at: \(position)")
        
        // Create multiple expanding circles for sonar effect
        for i in 0..<3 {
            let delay = Double(i) * 0.3
            
            let pulse = SKShapeNode(circleOfRadius: 10)
            pulse.strokeColor = UIColor.systemBlue
            pulse.fillColor = UIColor.systemBlue.withAlphaComponent(0.3)
            pulse.lineWidth = 3
            pulse.position = position
            pulse.zPosition = 60
            pulse.alpha = 1.0
            
            addChild(pulse)
            
            // Animate: scale up and fade out
            let wait = SKAction.wait(forDuration: delay)
            let scaleUp = SKAction.scale(to: 8.0, duration: 1.0)
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            let animateGroup = SKAction.group([scaleUp, fadeOut])
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([wait, animateGroup, remove])
            pulse.run(sequence)
        }
    }
    
    // MARK: - Magnifier
    
    private func updateMagnifier(at position: CGPoint) {
        guard let imageNode = imageNode else { return }
        
        // Check if touch is within the image bounds
        guard imageNode.contains(position) else {
            magnifierNode?.removeFromParent()
            magnifierNode = nil
            return
        }
        
        // Remove existing magnifier
        magnifierNode?.removeFromParent()
        
        // Create new magnifier node
        let magnifier = SKNode()
        magnifier.zPosition = 100
        
        // Create the lens background (white circle with shadow effect)
        let lensBackground = SKShapeNode(circleOfRadius: magnifierRadius + 4)
        lensBackground.fillColor = .white
        lensBackground.strokeColor = .gray
        lensBackground.lineWidth = 2
        lensBackground.zPosition = 0
        magnifier.addChild(lensBackground)
        
        // Create the lens content using a crop node
        let lensContent = SKCropNode()
        
        // Create circular mask
        let maskNode = SKShapeNode(circleOfRadius: magnifierRadius)
        maskNode.fillColor = .white
        lensContent.maskNode = maskNode
        
        // Create a scaled-up copy of the image for zooming
        let zoomedSprite = SKSpriteNode(texture: originalTexture)
        // Scale up the image size by zoom factor
        zoomedSprite.size = CGSize(
            width: imageNode.size.width * zoomFactor,
            height: imageNode.size.height * zoomFactor
        )
        
        // Calculate offset to center the touch point in the lens
        // Convert touch position to image-local coordinates
        let touchOffsetX = position.x - imageNode.position.x
        let touchOffsetY = position.y - imageNode.position.y
        
        // Scale the offset by zoom factor and negate to position correctly
        zoomedSprite.position = CGPoint(
            x: -touchOffsetX * zoomFactor,
            y: -touchOffsetY * zoomFactor
        )
        
        lensContent.addChild(zoomedSprite)
        lensContent.zPosition = 1
        magnifier.addChild(lensContent)
        
        // Add lens border
        let lensBorder = SKShapeNode(circleOfRadius: magnifierRadius)
        lensBorder.strokeColor = .darkGray
        lensBorder.lineWidth = 3
        lensBorder.fillColor = .clear
        lensBorder.zPosition = 2
        magnifier.addChild(lensBorder)
        
        // Position magnifier above the touch point so it's visible
        var magnifierPosition = CGPoint(x: position.x, y: position.y + magnifierRadius + 30)
        
        // Keep magnifier within scene bounds
        let minX = magnifierRadius + 5
        let maxX = size.width - magnifierRadius - 5
        let minY = magnifierRadius + 5
        let maxY = size.height - magnifierRadius - 5
        
        magnifierPosition.x = max(minX, min(maxX, magnifierPosition.x))
        magnifierPosition.y = max(minY, min(maxY, magnifierPosition.y))
        
        magnifier.position = magnifierPosition
        
        addChild(magnifier)
        magnifierNode = magnifier
    }
}
