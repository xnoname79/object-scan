import SwiftUI
import SceneKit

/// 3D model preview with rotation, zoom, and export options
struct ModelPreviewView: View {
    let object: ScannedObject
    @EnvironmentObject var scanManager: ScanManager
    @State private var selectedFormat: ExportFormat = .usdz
    @State private var isExporting = false
    @State private var showShareSheet = false
    @State private var exportedURL: URL?

    var body: some View {
        VStack(spacing: 0) {
            // 3D Preview
            SceneKitPreview(meshURL: object.meshFileURL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Info & Export panel
            VStack(spacing: 16) {
                // Mesh info
                HStack {
                    Label("\(object.vertexCount)", systemImage: "dot.radiowaves.up.forward")
                    Spacer()
                    Label("\(object.faceCount) faces", systemImage: "triangle")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                // Export controls
                HStack {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)

                    Button(action: exportModel) {
                        if isExporting {
                            ProgressView()
                        } else {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isExporting)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationTitle(object.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedURL {
                ShareSheet(url: url)
            }
        }
    }

    private func exportModel() {
        isExporting = true
        Task {
            do {
                let url = try await scanManager.exportObject(object, format: selectedFormat)
                exportedURL = url
                showShareSheet = true
            } catch {
                // Handle error
            }
            isExporting = false
        }
    }
}

/// UIActivityViewController wrapper for sharing exported files
struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
