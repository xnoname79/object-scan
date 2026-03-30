import SwiftUI
import ARKit
import RealityKit

struct ScanView: View {
    @EnvironmentObject var scanManager: ScanManager
    @StateObject private var arSession = ARSessionManager()

    var body: some View {
        NavigationStack {
            ZStack {
                // AR Camera View
                ARViewContainer(arSession: arSession)
                    .ignoresSafeArea()

                // Overlay UI
                VStack {
                    // Status bar
                    ScanStatusBar(
                        trackingState: arSession.trackingState,
                        pointCount: scanManager.pointCount
                    )

                    Spacer()

                    // Controls
                    ScanControlsView(
                        scanState: scanManager.scanState,
                        onStart: {
                            arSession.startSession()
                            scanManager.startScan()
                        },
                        onStop: {
                            scanManager.stopScan()
                            arSession.pauseSession()
                        },
                        onCancel: {
                            scanManager.cancelScan()
                            arSession.pauseSession()
                        }
                    )
                }
            }
            .navigationTitle("Object Scan")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                arSession.scanManager = scanManager
            }
            .alert("Scan Error", isPresented: .constant(scanManager.scanState.isError)) {
                Button("OK") { scanManager.cancelScan() }
            } message: {
                if case .failed(let msg) = scanManager.scanState {
                    Text(msg)
                }
            }
        }
    }
}

// MARK: - Helpers

extension ScanState {
    var isError: Bool {
        if case .failed = self { return true }
        return false
    }
}

#Preview {
    ScanView()
        .environmentObject(ScanManager())
}
