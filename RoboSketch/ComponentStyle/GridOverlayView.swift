//
//  GridOverlayView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//

import SwiftUI

struct GridOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let cellSize: CGFloat = 50.0
                let width = geometry.size.width
                let height = geometry.size.height
                
                // vertical
                stride(from: 0, through: width, by: cellSize).forEach { x in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                // horizontal
                stride(from: 0, through: height, by: cellSize).forEach { y in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}
