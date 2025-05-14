//
//  ColoredPath.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-22.
//  Updated by Jarin Thundathil on 2025-04-04.

import SwiftUI

struct ColoredPath: Identifiable, Hashable {
    // likely will need to include the robotName optionally
    let id = UUID()
    let path: UIBezierPath
    let encodedPath: String
    let color: Color
    var nodes: [Node] = []
    var isSelected: Bool = false
}
