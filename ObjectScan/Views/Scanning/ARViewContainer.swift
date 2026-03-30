import SwiftUI
import RealityKit
import ARKit

/// UIViewRepresentable wrapper for ARView with LiDAR mesh visualization
struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arSession: ARSessionManager

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session = arSession.session
        arView.automaticallyConfigureSession = false

        // Enable mesh visualization for debugging/feedback
        arView.debugOptions.insert(.showSceneUnderstanding)

        // Environment setup
        arView.environment.sceneUnderstanding.options = [
            .occlusion,
            .receivesLighting,
            .physics
        ]

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Update mesh visualization based on scan state
    }
}
