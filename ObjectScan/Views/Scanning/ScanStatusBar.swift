import SwiftUI
import ARKit

struct ScanStatusBar: View {
    let trackingState: ARCamera.TrackingState
    let pointCount: Int

    var body: some View {
        HStack {
            // Tracking indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(trackingColor)
                    .frame(width: 10, height: 10)
                Text(trackingText)
                    .font(.caption)
            }

            Spacer()

            // Point count
            HStack(spacing: 4) {
                Image(systemName: "dot.radiowaves.up.forward")
                Text("\(pointCount) vertices")
                    .font(.caption.monospacedDigit())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private var trackingColor: Color {
        switch trackingState {
        case .normal: return .green
        case .limited: return .yellow
        case .notAvailable: return .red
        }
    }

    private var trackingText: String {
        switch trackingState {
        case .normal:
            return "Tracking OK"
        case .limited(let reason):
            switch reason {
            case .initializing: return "Initializing..."
            case .excessiveMotion: return "Move slower"
            case .insufficientFeatures: return "Not enough features"
            case .relocalizing: return "Relocalizing..."
            @unknown default: return "Limited tracking"
            }
        case .notAvailable:
            return "Tracking unavailable"
        }
    }
}
