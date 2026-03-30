import Foundation
import ARKit
import RealityKit
import Combine

/// Main manager coordinating the 3D scanning pipeline
@MainActor
class ScanManager: ObservableObject {
    @Published var scanState: ScanState = .ready
    @Published var scanQuality: ScanQuality = .medium
    @Published var scannedObjects: [ScannedObject] = []
    @Published var currentMeshAnchors: [ARMeshAnchor] = []
    @Published var scanProgress: Float = 0.0
    @Published var pointCount: Int = 0

    private let meshProcessor = MeshProcessor()
    private let storageService = StorageService()
    private let exportService = ExportService()

    init() {
        loadSavedScans()
    }

    // MARK: - Scan Lifecycle

    func startScan() {
        scanState = .scanning
        currentMeshAnchors = []
        scanProgress = 0.0
        pointCount = 0
    }

    func stopScan() {
        scanState = .processing
        processMesh()
    }

    func cancelScan() {
        scanState = .ready
        currentMeshAnchors = []
        scanProgress = 0.0
    }

    // MARK: - Mesh Updates from ARSession

    func didUpdateMeshAnchors(_ anchors: [ARMeshAnchor]) {
        currentMeshAnchors = anchors
        pointCount = anchors.reduce(0) { $0 + $1.geometry.vertices.count }
    }

    // MARK: - Processing

    private func processMesh() {
        Task {
            do {
                let scannedObject = try await meshProcessor.processAnchors(
                    currentMeshAnchors,
                    quality: scanQuality
                )
                try storageService.save(scannedObject)
                scannedObjects.insert(scannedObject, at: 0)
                scanState = .completed
            } catch {
                scanState = .failed(error.localizedDescription)
            }
        }
    }

    // MARK: - Export

    func exportObject(_ object: ScannedObject, format: ExportFormat) async throws -> URL {
        return try await exportService.export(object, format: format)
    }

    // MARK: - Storage

    func deleteObject(_ object: ScannedObject) {
        storageService.delete(object)
        scannedObjects.removeAll { $0.id == object.id }
    }

    private func loadSavedScans() {
        scannedObjects = storageService.loadAll()
    }
}
