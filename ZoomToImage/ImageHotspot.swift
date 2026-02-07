//
//  ImageHotspot.swift
//  ZoomToImage
//
//  Created by AI Assistant on 07/02/26.
//

import Foundation

/// Represents a clickable region on the image using normalized coordinates.
/// Coordinates are relative to the image (0.0 to 1.0):
/// - (0.0, 0.0) = bottom-left corner
/// - (1.0, 1.0) = top-right corner
struct ImageHotspot: Identifiable {
    let id: String
    
    /// X position (0.0 = left edge, 1.0 = right edge)
    let normalizedX: CGFloat
    
    /// Y position (0.0 = bottom edge, 1.0 = top edge)
    let normalizedY: CGFloat
    
    /// Click radius relative to image width (e.g., 0.05 = 5% of image width)
    let normalizedRadius: CGFloat
    
    init(id: String, normalizedX: CGFloat, normalizedY: CGFloat, normalizedRadius: CGFloat) {
        self.id = id
        self.normalizedX = normalizedX
        self.normalizedY = normalizedY
        self.normalizedRadius = normalizedRadius
    }
}
