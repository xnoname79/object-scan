import Foundation

/// Manages persistence of scanned objects metadata
class StorageService {
    private let fileManager = FileManager.default
    private var metadataURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("scans_metadata.json")
    }

    func save(_ object: ScannedObject) throws {
        var objects = loadAll()
        objects.insert(object, at: 0)
        let data = try JSONEncoder().encode(objects)
        try data.write(to: metadataURL, options: .atomic)
    }

    func loadAll() -> [ScannedObject] {
        guard fileManager.fileExists(atPath: metadataURL.path),
              let data = try? Data(contentsOf: metadataURL),
              let objects = try? JSONDecoder().decode([ScannedObject].self, from: data)
        else {
            return []
        }
        return objects
    }

    func delete(_ object: ScannedObject) {
        // Remove mesh file
        if let meshURL = object.meshFileURL {
            try? fileManager.removeItem(at: meshURL)
        }
        // Remove thumbnail
        if let thumbURL = object.thumbnailURL {
            try? fileManager.removeItem(at: thumbURL)
        }
        // Update metadata
        var objects = loadAll()
        objects.removeAll { $0.id == object.id }
        if let data = try? JSONEncoder().encode(objects) {
            try? data.write(to: metadataURL, options: .atomic)
        }
    }
}
