import Foundation

enum ScanState: Equatable {
    case ready
    case scanning
    case processing
    case completed
    case failed(String)
}

enum ScanQuality: String, CaseIterable {
    case preview = "Preview"
    case medium = "Medium"
    case full = "Full"

    var description: String {
        switch self {
        case .preview: return "Fast scan, lower detail"
        case .medium: return "Balanced quality and speed"
        case .full: return "Highest detail, slower processing"
        }
    }
}
