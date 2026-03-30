import SwiftUI

struct ScanControlsView: View {
    let scanState: ScanState
    let onStart: () -> Void
    let onStop: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            switch scanState {
            case .ready, .completed, .failed:
                Button(action: onStart) {
                    ScanButton(icon: "record.circle", color: .red, label: "Start Scan")
                }

            case .scanning:
                Button(action: onCancel) {
                    ScanButton(icon: "xmark.circle.fill", color: .gray, label: "Cancel")
                }

                Button(action: onStop) {
                    ScanButton(icon: "stop.circle.fill", color: .red, label: "Finish")
                }

            case .processing:
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Processing mesh...")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.bottom, 40)
    }
}

struct ScanButton: View {
    let icon: String
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.white)
        }
    }
}
