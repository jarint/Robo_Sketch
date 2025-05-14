//
//  SnackbarView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-24.
//
import SwiftUI

struct SnackbarView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .foregroundColor(.white)
            .cornerRadius(20)
            .padding(.horizontal)
            .background(Color.red.opacity(0.8))
    }
}
