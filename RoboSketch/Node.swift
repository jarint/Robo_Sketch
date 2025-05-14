//
//  Node.swift
//  RoboSketch
//
//  Created by Jarin Thundathil on 2025-03-31.
//


import SwiftUI

struct Node: Identifiable, Hashable {
    let id = UUID()
    var position: CGPoint
    var selectedOption: String?
}
