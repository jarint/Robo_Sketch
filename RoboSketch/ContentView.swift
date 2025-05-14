import SwiftUI
import PencilKit


// MARK: - ContentView
extension Notification.Name {
    static let snackbarMessage = Notification.Name("snackbarMessage")
}

struct ContentView: View {
    //@State private var drawingColor: Color = .red
    @State private var paths: [ColoredPath] = []  // Store finalized path objects
    // State for robot selection and drawing color
    @State private var selectedRobot: String? = "Robot 1"
    @State private var showBluetoothModal = false 
    @State private var snackbarMessage: String? = nil  // Snackbar message state
    @State private var clearSignal: Bool = false
    @StateObject private var drawingContext = DrawingContext()

    // Define a list of robots with their corresponding colors.
    let robots: [(name: String, color: Color)] = [
        ("Robot 1", .red),
        ("Robot 2", .blue),
        ("Robot 3", .green),
        ("Robot 4", .teal)
    ]
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Top: Robot selector buttons
                HStack {
                    ForEach(robots, id: \.name) { robot in
                        RobotButton(
                            robotName: robot.name,
                            robotColor: robot.color,
                            selectedRobot: $selectedRobot,
                            drawingColor: $drawingContext.drawingColor,
                            onBluetooth: {
                                showBluetoothModal.toggle()
                            }
                        )
                    }
                }
                .padding()

                ZStack {
                    GridOverlayView()
                    SketchCanvasView(context: drawingContext, paths: $paths, clearSignal: $clearSignal)
                    PathsOverlayView(paths: $paths)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                //ActionBar(paths: $paths)
                ActionBar(paths: $paths, clearSignal: $clearSignal)
            }
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $showBluetoothModal) {
                BluetoothModalView(
                    onBluetooth: {
                        showBluetoothModal.toggle()
                    }
                )
            }
            
            // Snackbar overlay
            if let message = snackbarMessage {
                SnackbarView(message: message)
                    .transition(.move(edge: .bottom))
                    .padding(.bottom, 100)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                snackbarMessage = nil
                            }
                        }
                    }
            }
        }

        .onReceive(NotificationCenter.default.publisher(for: .snackbarMessage)) { notification in
            if let message = notification.object as? String {
                withAnimation {
                    snackbarMessage = message
                }

                // Auto-dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        // Only clear if the message hasn't been replaced by a new one
                        if snackbarMessage == message {
                            snackbarMessage = nil
                        }
                    }
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
