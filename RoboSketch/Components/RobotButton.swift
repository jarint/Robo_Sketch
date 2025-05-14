//
//  RobotButton.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//  Updated by Jarin Thundathil on 2025-04-04.

import SwiftUI

// RobotButton: Tapping a robot button once sets its color; tapping it again shows the Bluetooth modal.
struct RobotButton: View {
    var robotName: String
    var robotColor: Color
    @Binding var selectedRobot: String?
    @Binding var drawingColor: Color
    var onBluetooth: () -> Void

    var body: some View {
        Button(action: {
            if selectedRobot != robotName {
                // First tap: select this robot and change the drawing color.
                selectedRobot = robotName
                drawingColor = robotColor
            } else {
                // Second tap on the same button: show the Bluetooth modal.
                onBluetooth()
            }
        }) {
            Text(selectedRobot == robotName ? "Connect Robot" : robotName)
                .fontWeight(selectedRobot == robotName ? .bold : .semibold)
                .foregroundColor(.white)
                .padding()
                .frame(minWidth: 100)
        }
        .buttonStyle(ClickableRoundedButtonStyle(
            backgroundColor: robotColor,
            isSelected: selectedRobot == robotName
        ))
    }
}

