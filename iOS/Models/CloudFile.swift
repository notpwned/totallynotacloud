import Foundation

/// Модель файла в облачном хранилище
struct CloudFile: Identifiable, Codable {
    let id: String
    var name: String
    let size: Int64
    let mimeType: String
    let uploadedAt: Date
    var updatedAt: Date
    var isDirectory: Bool = false
    var parentId: String?
    
    /// Форматированный размер файла
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    /// Иконка в зависимости от типа файла
    var fileIcon: String {
        if isDirectory {
            return "folder.fill"
        }
        
        switch mimeType {
        case let type where type.contains("image"):
            return "photo.fill"
        case let type where type.contains("video"):
            return "film.fill"
        case let type where type.contains("audio"):
            return "music.note"
        case let type where type.contains("pdf"):
            return "doc.fill"
        case let type where type.contains("text"):
            return "doc.text.fill"
        case let type where type.contains("archive"):
            return "archivebox.fill"
        default:
            return "doc.fill"
        }
    }
}

/// Модель для ответа от сервера при загрузке файла
struct UploadResponse: Codable {
    let id: String
    let name: String
    let size: Int64
    let url: String
}

/// Модель для отслеживания статуса загрузки
struct UploadProgress: Identifiable {
    let id: String = UUID().uuidString
    let fileName: String
    var progress: Double = 0.0
    var isComplete: Bool = false
    var error: String?
}
