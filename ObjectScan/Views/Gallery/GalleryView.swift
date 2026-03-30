import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var scanManager: ScanManager

    var body: some View {
        NavigationStack {
            Group {
                if scanManager.scannedObjects.isEmpty {
                    ContentUnavailableView(
                        "No Scans Yet",
                        systemImage: "cube.transparent",
                        description: Text("Scan an object to see it here")
                    )
                } else {
                    List {
                        ForEach(scanManager.scannedObjects) { object in
                            NavigationLink(destination: ModelPreviewView(object: object)) {
                                GalleryRowView(object: object)
                            }
                        }
                        .onDelete(perform: deleteObjects)
                    }
                }
            }
            .navigationTitle("My Scans")
        }
    }

    private func deleteObjects(at offsets: IndexSet) {
        for index in offsets {
            scanManager.deleteObject(scanManager.scannedObjects[index])
        }
    }
}

struct GalleryRowView: View {
    let object: ScannedObject

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary)
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "cube.fill")
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(object.name)
                    .font(.headline)
                Text("\(object.vertexCount) vertices · \(object.faceCount) faces")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(object.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
