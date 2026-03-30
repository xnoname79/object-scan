import ARKit
import ModelIO
import MetalKit

/// Processes ARMeshAnchors into a unified 3D mesh
class MeshProcessor {

    /// Combines all mesh anchors into a single ScannedObject with saved mesh file
    func processAnchors(_ anchors: [ARMeshAnchor], quality: ScanQuality) async throws -> ScannedObject {
        return try await Task.detached(priority: .userInitiated) {
            let meshDescriptor = self.buildMeshDescriptor(from: anchors)
            let (vertexCount, faceCount) = self.countGeometry(anchors)

            // Save mesh to file
            let fileURL = try self.saveMesh(meshDescriptor, anchors: anchors)

            return ScannedObject(
                name: "Scan \(Date().formatted(date: .abbreviated, time: .shortened))",
                meshFileURL: fileURL,
                vertexCount: vertexCount,
                faceCount: faceCount
            )
        }.value
    }

    // MARK: - Geometry Extraction

    private func buildMeshDescriptor(from anchors: [ARMeshAnchor]) -> MDLMeshBufferAllocator {
        return MDLMeshBufferDataAllocator()
    }

    /// Extract vertex positions from an ARMeshAnchor
    func extractVertices(from anchor: ARMeshAnchor) -> [SIMD3<Float>] {
        let geometry = anchor.geometry
        let vertexBuffer = geometry.vertices
        var vertices: [SIMD3<Float>] = []
        vertices.reserveCapacity(vertexBuffer.count)

        for i in 0..<vertexBuffer.count {
            let vertexPointer = vertexBuffer.buffer.contents()
                .advanced(by: vertexBuffer.stride * i)
            let vertex = vertexPointer.assumingMemoryBound(to: SIMD3<Float>.self).pointee

            // Transform to world coordinates
            let worldVertex = anchor.transform * SIMD4<Float>(vertex.x, vertex.y, vertex.z, 1.0)
            vertices.append(SIMD3<Float>(worldVertex.x, worldVertex.y, worldVertex.z))
        }

        return vertices
    }

    /// Extract face indices from an ARMeshAnchor
    func extractFaces(from anchor: ARMeshAnchor) -> [UInt32] {
        let geometry = anchor.geometry
        let faceBuffer = geometry.faces
        var indices: [UInt32] = []
        indices.reserveCapacity(faceBuffer.count * 3)

        for i in 0..<faceBuffer.count {
            let facePointer = faceBuffer.buffer.contents()
                .advanced(by: faceBuffer.indexCountPerPrimitive * faceBuffer.bytesPerIndex * i)

            for j in 0..<faceBuffer.indexCountPerPrimitive {
                let indexPointer = facePointer.advanced(by: j * faceBuffer.bytesPerIndex)
                let index = indexPointer.assumingMemoryBound(to: UInt32.self).pointee
                indices.append(index)
            }
        }

        return indices
    }

    // MARK: - Mesh Saving

    private func saveMesh(_ allocator: MDLMeshBufferAllocator, anchors: [ARMeshAnchor]) throws -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let meshesDir = documentsURL.appendingPathComponent("Meshes", isDirectory: true)
        try FileManager.default.createDirectory(at: meshesDir, withIntermediateDirectories: true)

        let fileName = UUID().uuidString + ".obj"
        let fileURL = meshesDir.appendingPathComponent(fileName)

        // Build combined OBJ data
        var objContent = "# ObjectScan mesh export\n"
        var vertexOffset: UInt32 = 0

        for anchor in anchors {
            let vertices = extractVertices(from: anchor)
            let faces = extractFaces(from: anchor)

            // Write vertices
            for v in vertices {
                objContent += "v \(v.x) \(v.y) \(v.z)\n"
            }

            // Write faces (OBJ indices are 1-based)
            let indicesPerFace = anchor.geometry.faces.indexCountPerPrimitive
            for i in stride(from: 0, to: faces.count, by: indicesPerFace) {
                let faceIndices = (0..<indicesPerFace).map { faces[i + $0] + vertexOffset + 1 }
                objContent += "f \(faceIndices.map { String($0) }.joined(separator: " "))\n"
            }

            vertexOffset += UInt32(vertices.count)
        }

        try objContent.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    private func countGeometry(_ anchors: [ARMeshAnchor]) -> (vertices: Int, faces: Int) {
        let vertices = anchors.reduce(0) { $0 + $1.geometry.vertices.count }
        let faces = anchors.reduce(0) { $0 + $1.geometry.faces.count }
        return (vertices, faces)
    }
}
