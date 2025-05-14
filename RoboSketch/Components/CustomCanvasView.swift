//
//  CustomCanvasView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-22.
//
import SwiftUI
import PencilKit

class CustomCanvasView: PKCanvasView {
    var onStrokeEnd: ((PKStroke?) -> Void)?
    private var conversionTimer: Timer?

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        // Invalidate any previous timer.
        conversionTimer?.invalidate()
        // Schedule conversion after a short delay.
        conversionTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            // Grab the last stroke if available.
            let stroke = self.drawing.strokes.last
            self.onStrokeEnd?(stroke)
        }
    }
}
