import Foundation

struct UploadProgress: Identifiable {
    let id = UUID()
    let fileName: String
    var progress: Double
    var isComplete = false
}
