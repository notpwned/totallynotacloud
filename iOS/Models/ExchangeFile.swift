import Foundation

struct ExchangeFile: Identifiable, Codable {
    let id: String
    let name: String
    let size: Int64
    let mimeType: String
    let uploadedAt: Date
    let expiresAt: Date
    let accessHash: String
    let downloadCount: Int
    let maxDownloads: Int
    let encryptedData: Data?
    
    init(id: String = UUID().uuidString, name: String, size: Int64, mimeType: String, uploadedAt: Date = Date(), expiresAt: Date, accessHash: String, downloadCount: Int = 0, maxDownloads: Int = -1, encryptedData: Data? = nil) {
        self.id = id
        self.name = name
        self.size = size
        self.mimeType = mimeType
        self.uploadedAt = uploadedAt
        self.expiresAt = expiresAt
        self.accessHash = accessHash
        self.downloadCount = downloadCount
        self.maxDownloads = maxDownloads
        self.encryptedData = encryptedData
    }
}
