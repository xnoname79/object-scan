import Foundation
import ModelIO
import SceneKit

/// Handles exporting 3D meshes to various file formats
class ExportService {

    func export(_ object: ScannedObject, format: ExportFormat) async throws -> URL {
        guard let sourceURL = object.meshFileURL else {
            throw ExportError.noMeshFile
        }

        let outputDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Exports", isDirectory: true)
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        let outputURL = outputDir.appendingPathComponent("\(object.name).\(format.fileExtension)")

        switch format {
        case .obj:
            // Source is already OBJ, just copy
            if FileManager.default.fileExists(atPath: outputURL.path) {
                try FileManager.default.removeItem(at: outputURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: outputURL)

        case .usdz:
            try exportToUSDZ(source: sourceURL, destination: outputURL)

        case .stl:
            try exportToSTL(source: sourceURL, destination: outputURL)

        case .ply:
            try exportToPLY(source: sourceURL, destination: outputURL)
        }

        return outputURL
    }

    // MARK: - Format-specific exporters

    private func exportToUSDZ(source: URL, destination: URL) throws {
        let asset = MDLAsset(url: source)
        try asset.export(to: destination)
    }

    private func exportToSTL(source: URL, destination: URL) throws {
        let asset = MDLAsset(url: source)
        try asset.export(to: destination)
    }

    private func exportToPLY(source: URL, destination: URL) throws {
        let asset = MDLAsset(url: source)
        try asset.export(to: destination)
    }
}

// MARK: - Helpers

extension ExportFormat {
    var fileExtension: String {
        switch self {
        case .usdz: return "usdz"
        case .obj: return "obj"
        case .stl: return "stl"
        case .ply: return "ply"
        }
    }
}

enum ExportError: LocalizedError {
    case noMeshFile
    case exportFailed(String)

    var errorDescription: String? {
        switch self {
        case .noMeshFile: return "No mesh file found for this scan"
        case .exportFailed(let reason): return "Export failed: \(reason)"
        }
    }
}
