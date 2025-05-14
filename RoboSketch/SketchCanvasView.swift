//
//  SketchCanvasView.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-03-18.
//  Updated by Jarin Thundathil on 2025-04-04.

import SwiftUI
import PencilKit
import CoreGraphics

extension CGPath {
    func forEach(_ body: @escaping (CGPathElement) -> Void) {
        let wrapper = BodyWrapper(body: body)
        let pointer = Unmanaged.passRetained(wrapper).toOpaque()
        self.apply(info: pointer) { (info, element) in
            let wrapper = Unmanaged<BodyWrapper>.fromOpaque(info!).takeUnretainedValue()
            wrapper.body(element.pointee)
        }
        Unmanaged<BodyWrapper>.fromOpaque(pointer).release()
    }
}

private class BodyWrapper {
    let body: (CGPathElement) -> Void
    init(body: @escaping (CGPathElement) -> Void) {
        self.body = body
    }
}


extension UIBezierPath {
    func toJSON() -> String? {
        var commands: [[String: Any]] = []
        
        self.cgPath.forEach { element in
            switch element.type {
            case .moveToPoint:
                let point = element.points[0]
                // Always add a new moveTo command.
                commands.append(["cmd": "moveTo", "points": [["x": point.x, "y": point.y]]])
                
            case .addLineToPoint:
                let point = element.points[0]
                // If the last command is a lineTo, append the point. Otherwise, create a new one.
                if let last = commands.last, let lastCmd = last["cmd"] as? String, lastCmd == "lineTo" {
                    var lastPoints = last["points"] as? [[String: CGFloat]] ?? []
                    lastPoints.append(["x": point.x, "y": point.y])
                    commands[commands.count - 1]["points"] = lastPoints
                } else {
                    commands.append(["cmd": "lineTo", "points": [["x": point.x, "y": point.y]]])
                }
                
            case .addQuadCurveToPoint:
                let controlPoint = element.points[0]
                let endPoint = element.points[1]
                commands.append([
                    "cmd": "quadCurveTo",
                    "points": [
                        ["controlX": controlPoint.x, "controlY": controlPoint.y],
                        ["x": endPoint.x, "y": endPoint.y]
                    ]
                ])
                
            case .addCurveToPoint:
                let controlPoint1 = element.points[0]
                let controlPoint2 = element.points[1]
                let endPoint = element.points[2]
                commands.append([
                    "cmd": "curveTo",
                    "points": [
                        ["control1X": controlPoint1.x, "control1Y": controlPoint1.y],
                        ["control2X": controlPoint2.x, "control2Y": controlPoint2.y],
                        ["x": endPoint.x, "y": endPoint.y]
                    ]
                ])
                
            case .closeSubpath:
                commands.append(["cmd": "closePath"])
                
            @unknown default:
                break
            }
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: commands, options: [.prettyPrinted]),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}

class DrawingContext: ObservableObject {
    @Published var drawingColor: Color = .red
}

struct SketchCanvasView: UIViewRepresentable {
    @ObservedObject var context: DrawingContext
    @Binding var paths: [ColoredPath]
    @Binding var clearSignal: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = CustomCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput // change to pencilOnly

        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        //canvasView.tool = PKInkingTool(.pen, color: UIColor(drawingColor), width: 5)
        canvasView.tool = PKInkingTool(.pen, color: UIColor(self.context.drawingColor), width: 5)
        canvasView.delegate = context.coordinator
        
        // Capture the coordinator so we always refer to the updated parent values.
        let coordinator = context.coordinator

        (canvasView as? CustomCanvasView)?.onStrokeEnd = { stroke in
            guard let stroke = stroke else { return }

            // ✅ Use the latest drawing color from SwiftUI state (not stale parent copy)
            //let currentDrawingColor = self.drawingColor
            let currentDrawingColor = self.context.drawingColor

            if context.coordinator.hasPathWithColor(currentDrawingColor) {
                NotificationCenter.default.post(name: .snackbarMessage,
                                                object: "Additional paths of the same color are not allowed")
                canvasView.drawing = PKDrawing()
                return
            }

            context.coordinator.convertStrokeToPath(stroke, in: canvasView, strokeColor: currentDrawingColor)
        }
        
        return canvasView
    }

    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = PKInkingTool(.pen, color: UIColor(self.context.drawingColor), width: 5)

        if clearSignal {
            uiView.drawing = PKDrawing()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator to observe drawing changes.
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: SketchCanvasView

        init(_ parent: SketchCanvasView) {
            self.parent = parent
        }
        
        func hasPathWithColor(_ color: Color) -> Bool {
            return parent.paths.contains(where: { $0.color == color })
        }
        
        func convertStrokeToPath(_ stroke: PKStroke, in canvasView: PKCanvasView, strokeColor: Color) {
            // Capture the current drawing color before any delay or further processing.
            let newPath = UIBezierPath()
            let points = stroke.path.interpolatedPoints(by: PKStrokePath.InterpolatedSlice.Stride.distance(50.0))
            let pointArray = Array(points)
            guard let firstPoint = pointArray.first else { return }
            newPath.move(to: firstPoint.location)
            for point in pointArray.dropFirst() {
                newPath.addLine(to: point.location)
            }
            
            
            let start = pointArray.first?.location ?? .zero
            let end = pointArray.last?.location ?? .zero
            let nodes = [Node(position: start, selectedOption: nil), Node(position: end, selectedOption: nil)]

            let encoded = newPath.toJSON() ?? ""
            let coloredPath = ColoredPath(
                path: newPath,
                //encodedPath: "", // TODO: generate real encoding later if needed
                encodedPath: encoded,
                color: strokeColor,
                nodes: nodes
            )
//            self.parent.paths.append(coloredPath)
//            
//            print("Final stroke converted to path")
//            // JARIN: This is where the points on the line are displayed
//                // will likely use some cleaned up version of these for path encoding
//            print(coloredPath.encodedPath)
            
            self.parent.paths.append(coloredPath)
            canvasView.drawing = PKDrawing()  // ✅ clear the underlying stroke

            print("Final stroke converted to path")
            print(coloredPath.encodedPath)
        }



    }

}
