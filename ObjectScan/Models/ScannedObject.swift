import Foundation
import RealityKit

/// Represents a completed 3D scan
struct ScannedObject: Identifiable, Codable {
    let id: UUID
    var name: String
    let createdAt: Date
    var meshFileURL: URL?
    var thumbnailURL: URL?
    var vertexCount: Int
    var faceCount: Int
    var exportFormat: ExportFormat

    init(
        id: UUID = UUID(),
        name: String = "Untitled Scan",
        createdAt: Date = Date(),
        meshFileURL: URL? = nil,
        thumbnailURL: URL? = nil,
        vertexCount: Int = 0,
        faceCount: Int = 0,
        exportFormat: ExportFormat = .usdz
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.meshFileURL = meshFileURL
        self.thumbnailURL = thumbnailURL
        self.vertexCount = vertexCount
        self.faceCount = faceCount
        self.exportFormat = exportFormat
    }
}

enum ExportFormat: String, Codable, CaseIterable {
    case usdz = "USDZ"
    case obj = "OBJ"
    case stl = "STL"
    case ply = "PLY"
}
