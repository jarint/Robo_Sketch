//
//  ClickableRoundedButtonStyle.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//
import SwiftUI

struct ClickableRoundedButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    var isSelected: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(minWidth: 100)
            .background(
                configuration.isPressed
                ? backgroundColor.opacity(0.3)
                : (
                    isSelected
                    ? backgroundColor.opacity(0.8)
                    : backgroundColor.opacity(0.5)
                )
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? backgroundColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(configuration.isPressed ? 0.2 : 0.5),
                    radius: configuration.isPressed ? 2 : 5,
                    x: 0,
                    y: configuration.isPressed ? 1 : 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
