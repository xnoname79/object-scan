import ARKit
import RealityKit
import Combine

/// Manages ARSession configuration and delegates for LiDAR mesh scanning
class ARSessionManager: NSObject, ObservableObject {
    @Published var isLiDARAvailable: Bool = false
    @Published var trackingState: ARCamera.TrackingState = .notAvailable
    @Published var sessionError: String?

    let session = ARSession()
    weak var scanManager: ScanManager?

    override init() {
        super.init()
        session.delegate = self
        isLiDARAvailable = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    }

    // MARK: - Session Configuration

    func startSession() {
        let config = ARWorldTrackingConfiguration()

        // Enable LiDAR mesh scanning
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            config.sceneReconstruction = .meshWithClassification
        } else if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }

        // Environment texturing for realistic appearance
        config.environmentTexturing = .automatic

        // Enable plane detection for surface reference
        config.planeDetection = [.horizontal, .vertical]

        // High resolution frame capture
        if let hiResFormat = ARWorldTrackingConfiguration.supportedVideoFormats
            .filter({ $0.captureDevicePosition == .back })
            .max(by: { $0.imageResolution.width < $1.imageResolution.width }) {
            config.videoFormat = hiResFormat
        }

        session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

    func pauseSession() {
        session.pause()
    }

    func resetSession() {
        let config = session.configuration as? ARWorldTrackingConfiguration ?? ARWorldTrackingConfiguration()
        session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
}

// MARK: - ARSessionDelegate

extension ARSessionManager: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        trackingState = frame.camera.trackingState
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let meshAnchors = anchors.compactMap { $0 as? ARMeshAnchor }
        guard !meshAnchors.isEmpty else { return }
        Task { @MainActor in
            scanManager?.didUpdateMeshAnchors(
                session.currentFrame?.anchors.compactMap { $0 as? ARMeshAnchor } ?? []
            )
        }
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let meshAnchors = anchors.compactMap { $0 as? ARMeshAnchor }
        guard !meshAnchors.isEmpty else { return }
        Task { @MainActor in
            scanManager?.didUpdateMeshAnchors(
                session.currentFrame?.anchors.compactMap { $0 as? ARMeshAnchor } ?? []
            )
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionError = error.localizedDescription
    }

    func sessionWasInterrupted(_ session: ARSession) {
        sessionError = "Session interrupted"
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        sessionError = nil
    }
}
