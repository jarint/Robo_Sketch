//
//  ButtonStyle.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//

import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    var isSelected: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.black : Color.clear, lineWidth: 3)
            )
            .cornerRadius(10)
            .shadow(radius: configuration.isPressed ? 0 : 5)
            .padding([.leading, .trailing])
    }
}
