//
//  PathsOverlayView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-22.
//  Updated by Jarin Thundathil on 2025-04-04.



import SwiftUI

struct PathsOverlayView: View {
    @Binding var paths: [ColoredPath]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach($paths, id: \.id) { $coloredPath in
//                    let cp = coloredPath
                    // Draw the path
                    Path(coloredPath.path.cgPath)
                        .stroke(coloredPath.color, lineWidth: 5)
                    
                    // Draw interactive nodes
                    ForEach($coloredPath.nodes, id: \.id) { $node in
                        NodeView(node: $node, color: coloredPath.color)
                    }
                }
            }
        }
    }
}
