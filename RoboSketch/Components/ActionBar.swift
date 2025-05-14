import SwiftUI
extension Color {
    var name: String {
        // Adjust these names as needed.
        if self == .red { return "red" }
        else if self == .blue { return "blue" }
        else if self == .green { return "green" }
        else if self == .teal { return "teal" }
        return "unknown"
    }
}

struct ActionBar: View {
    @Binding var paths: [ColoredPath]
    @State private var undone: [ColoredPath] = []
    @Binding var clearSignal: Bool


    var body: some View {
        HStack {
            Button("Save") {
                if paths.count > 0 {
                    savePaths()
                } else{
                    NotificationCenter.default.post(name: .snackbarMessage,
                                                    object: "Nothing to save!")
                }
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: paths.count == 0 ? .gray : .orange))
            
            Button("Redo") {
                if let lastUndone = undone.popLast() {
                    paths.append(lastUndone)
                }else{
                    NotificationCenter.default.post(name: .snackbarMessage,
                                                    object: "Nothing to redo!")
                }
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: undone.count == 0 ? .gray : .yellow))
            
            Button("Undo") {
                if let last = paths.popLast() {
                    undone.append(last)
                }else{
                    NotificationCenter.default.post(name: .snackbarMessage,
                                                    object: "Nothing to undo!")
                }
            }
            .disabled(paths.isEmpty)
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: paths.count == 0 ? .gray : .blue))
            
            Button("Clear") {
                paths.removeAll()
                undone.removeAll()
                clearSignal.toggle() // Triggers PKCanvasView to clear
            }
            .disabled(paths.isEmpty)
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: paths.count == 0 ? .gray : .red))
            
            Button("Play") {
                generatePythonScript(from: paths)
            }
            .padding()
            .buttonStyle(RoundedButtonStyle(backgroundColor: .green))
        }
        .background(Color(UIColor.systemGray6))
    }
    
    func savePaths() {
        print("Number of paths to save: \(paths.count) \(paths[0].encodedPath)")
        
        // Locate the documents directory on the device.
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found.")
            return
        }
        
        // Specify the file URL (e.g., "paths.json").
        let fileURL = documentsDirectory.appendingPathComponent("paths.json")
        
        // Create an array to hold all the path dictionaries.
        var pathsArray: [[String: Any]] = []
        
        // Iterate over each ColoredPath.
        for coloredPath in paths {
            let encodedPathString = coloredPath.encodedPath
            if let data = encodedPathString.data(using: .utf8) {
                if let encodingObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                    let pathDict: [String: Any] = [
                        "color": coloredPath.color.name,
                        "encoding": encodingObject
                    ]
                    //                    print("Number of paths to save: \(paths.count) \(coloredPath.encodedPath)")
                    print(pathDict)
                    pathsArray.append(pathDict)
                } else {
                    print("Failed to convert encodedPath string into a JSON object")
                }
            } else {
                print("Failed to convert encodedPath to Data")
            }
        }
        
        
        
        // Convert the array into JSON data.
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: pathsArray, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
            print("Paths saved to: \(fileURL)")
        } catch {
            print("Error saving paths: \(error)")
        }
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("Python script generated at: \(fileURL.path)".replacingOccurrences(of: " ", with: "\\ "))
        } else {
            print("File does NOT exist at: \(fileURL.path)")
        }
    }
    
    func generatePythonScript(from paths: [ColoredPath]) {
        var scriptLines = [String]()
        
        // Header and initialization (using your picrawler syntax)
        scriptLines.append("from spider import Spider")
        scriptLines.append("from ezblock import print, delay")
        scriptLines.append("from Music import *")
        scriptLines.append("import math")
        scriptLines.append("")
        scriptLines.append("crawler = Spider([10,11,12,4,5,6,1,2,3,7,8,9])")
        scriptLines.append("speed = 1000")
        scriptLines.append("")
        NodeOptions.options.forEach { (key: String, value: String) in
            scriptLines.append("\(value)")
        }
        scriptLines.append("def main():")

        
        // Iterate over each ColoredPath
        for coloredPath in paths {
            print(coloredPath.nodes[0].selectedOption ?? "default value")
            if (coloredPath.nodes[0].selectedOption != nil) {
                scriptLines.append("    \(coloredPath.nodes[0].selectedOption?.lowercased() ?? "#")()")
            }
            let encoded = coloredPath.encodedPath
            if let data = encoded.data(using: .utf8) {
                do {
                    // Decode the top-level JSON as an array of command dictionaries.
                    if let commands = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        for command in commands {
                            guard let cmd = command["cmd"] as? String,
                                  let points = command["points"] as? [[String: Any]] else { continue }
                            
                            if cmd == "moveTo" {
                                // Process the "moveTo" command as the starting point.
                                if let pt = points.first,
                                   let x = pt["x"] as? Double,
                                   let y = pt["y"] as? Double {
                                    scriptLines.append("    # Starting point at (\(x), \(y))")
                                    scriptLines.append("    crawler.do_action(\"move\", 1, speed)")
                                    scriptLines.append("    delay(50)")
                                }
                            } else if cmd == "lineTo" {
                                scriptLines.append("    # Begin lineTo segment")
                                
                                // Variables for tracking previous point and heading.
                                var previousPoint: (x: Double, y: Double)? = nil
                                var previousHeading: Double? = nil
                                
                                // Variables for condensing turn commands.
                                var pendingTurnDirection: String? = nil  // "turn left angle" or "turn right angle"
                                var pendingTurnSteps = 0
                                
                                // Variable to accumulate forward steps.
                                var pendingForwardSteps = 0
                                
                                for pt in points {
                                    if let x = pt["x"] as? Double,
                                       let y = pt["y"] as? Double {
                                        // If we have a previous point, we can compute a heading.
                                        if let prev = previousPoint,
                                           let prevHeading = previousHeading {
                                            let dx = x - prev.x
                                            let dy = y - prev.y
                                            let currentHeading = atan2(dy, dx) * 180.0 / Double.pi
                                            
                                            // Compute the delta between headings, normalized to [-180, 180].
                                            let deltaAngle = fmod(currentHeading - prevHeading + 180.0, 360.0) - 180.0
                                            
                                            // Process turns only if change is 20° or more.
                                            if abs(deltaAngle) >= 20.0 {
                                                // Before processing a turn, flush any accumulated forward commands.
                                                if pendingForwardSteps > 0 {
                                                    scriptLines.append("    # Move forward by \(pendingForwardSteps) step\(pendingForwardSteps > 1 ? "s" : "")")
                                                    scriptLines.append("    crawler.do_action(\"forward\", \(pendingForwardSteps), speed)")
                                                    scriptLines.append("    delay(50)")
                                                    pendingForwardSteps = 0
                                                }
                                                
                                                // Map each 35° to one step.
                                                let turnSteps = Int(round(abs(deltaAngle) / 35.0))
                                                let currentDirection = deltaAngle > 0 ? "turn left angle" : "turn right angle"
                                                
                                                // If there is a pending turn with the same direction, accumulate steps.
                                                if let pending = pendingTurnDirection {
                                                    if pending == currentDirection {
                                                        pendingTurnSteps += turnSteps
                                                    } else {
                                                        // Flush the previous pending turn command.
                                                        scriptLines.append("    # Combined \(pending) by \(pendingTurnSteps) (approx \(pendingTurnSteps * 35)°)")
                                                        scriptLines.append("    crawler.do_action(\"\(pending)\", \(pendingTurnSteps), speed)")
                                                        scriptLines.append("    delay(50)")
                                                        // Start new pending turn.
                                                        pendingTurnDirection = currentDirection
                                                        pendingTurnSteps = turnSteps
                                                    }
                                                } else {
                                                    pendingTurnDirection = currentDirection
                                                    pendingTurnSteps = turnSteps
                                                }
                                                
                                                // Flush pending turn commands immediately.
                                                if let pending = pendingTurnDirection, pendingTurnSteps > 0 {
                                                    scriptLines.append("    # Combined \(pending) by \(pendingTurnSteps) (approx \(pendingTurnSteps * 35)°)")
                                                    scriptLines.append("    crawler.do_action(\"\(pending)\", \(pendingTurnSteps), speed)")
                                                    scriptLines.append("    delay(50)")
                                                    pendingTurnDirection = nil
                                                    pendingTurnSteps = 0
                                                }
                                                
                                                // Update the heading for next computation.
                                                previousHeading = currentHeading
                                            }
                                            // If the delta is below threshold, do nothing.
                                        }
                                        
                                        // Accumulate forward steps (each point represents one forward step).
                                        pendingForwardSteps += 1
                                        
                                        // Update tracking variables.
                                        if previousPoint == nil {
                                            // Initialize previousHeading if this is the first movement.
                                            previousHeading = nil
                                        } else {
                                            // For subsequent points, update previousHeading based on last movement.
                                            let dx = x - (previousPoint?.x ?? x)
                                            let dy = y - (previousPoint?.y ?? y)
                                            previousHeading = atan2(dy, dx) * 180.0 / Double.pi
                                        }
                                        previousPoint = (x, y)
                                    }
                                }
                                
                                // At the end of the segment, flush any pending turn or forward commands.
                                if let pending = pendingTurnDirection, pendingTurnSteps > 0 {
                                    scriptLines.append("    # Combined \(pending) by \(pendingTurnSteps) (approx \(pendingTurnSteps * 35)°)")
                                    scriptLines.append("    crawler.do_action(\"\(pending)\", \(pendingTurnSteps), speed)")
                                    scriptLines.append("    delay(50)")
                                    pendingTurnDirection = nil
                                    pendingTurnSteps = 0
                                }
                                
                                if pendingForwardSteps > 0 {
                                    scriptLines.append("    # Move forward by \(pendingForwardSteps) step\(pendingForwardSteps > 1 ? "s" : "")")
                                    scriptLines.append("    crawler.do_action(\"forward\", \(pendingForwardSteps), speed)")
                                    scriptLines.append("    delay(50)")
                                    pendingForwardSteps = 0
                                }
                            } else {
                                scriptLines.append("    # Unknown command: \(cmd)")
                            }
                        }
                        if (coloredPath.nodes[1].selectedOption != nil) {
                            scriptLines.append("    \(coloredPath.nodes[1].selectedOption?.lowercased() ?? "#")()")
                        }
                    } else {
                        print("Failed to decode JSON as an array for a path.")
                    }
                } catch {
                    print("Error decoding encodedPath: \(error)")
                }
            } else {
                print("Could not convert encodedPath to Data.")
            }
        }
        
        // End the script with the stand command.
//        scriptLines.append("    crawler.do_action(\"stand\", 1, speed)")
        scriptLines.append("")
        scriptLines.append("def forever():")
        scriptLines.append("    main()")
        
        // Join the generated lines into a single Python script.
        let script = scriptLines.joined(separator: "\n")
        
        // Save the generated script to the Documents directory.
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("generated_script.py")
            do {
                try script.write(to: fileURL, atomically: true, encoding: .utf8)
                print("code \(fileURL)".replacingOccurrences(of: "%20", with: "\\ ").replacingOccurrences(of: "file://", with: ""))
                
                // JARIN TODO: Try to make copy to clipboard work
                DispatchQueue.main.async {
                    UIPasteboard.general.string = "Hello world"
//                    UIPasteboard.general.string = script
                }
                print("Script copied to clipboard.")
            } catch {
                print("Error writing Python script: \(error)")
            }
        }
    }
}
