import Foundation
import Combine

class StorageService: ObservableObject {
    @Published var exchangeFiles: [ExchangeFile] = []
    @Published var isLoading = false
    @Published var uploadProgress: [UploadProgress] = []
    @Published var errorMessage: String?
    
    private let apiBaseURL = "https://api.totallynotacloud.local"
    private let cryptoService = CryptoService.shared
    private let keychainService = KeychainService.shared
    private var currentAccessKey: AccessKey?
    
    init() {}
    
    func generateNewAccessKey() throws -> (key: AccessKey, qrCode: String) {
        let keyId = UUID().uuidString
        let accessKey = cryptoService.generateAccessKey()
        
        let (publicKey, privateKey) = try cryptoService.generateKeyPair()
        
        let accessKeyModel = AccessKey(
            keyId: keyId,
            publicKey: publicKey,
            privateKey: privateKey,
            createdAt: Date(),
            permissions: ["read", "write", "delete"]
        )
        
        try keychainService.saveAccessKey(accessKeyModel)
        currentAccessKey = accessKeyModel
        
        let qrData = "\(keyId):\(accessKey)"
        return (accessKeyModel, qrData)
    }
    
    func importAccessKeyFromQR(_ qrData: String) throws {
        let components = qrData.split(separator: ":")
        guard components.count == 2 else {
            throw StorageError.invalidQRCode
        }
        
        let keyId = String(components[0])
        let accessKey = try keychainService.retrieveAccessKey(keyId: keyId)
        currentAccessKey = accessKey
    }
    
    func uploadFile(data: Data, name: String, mimeType: String) async {
        guard let accessKey = currentAccessKey else {
            DispatchQueue.main.async {
                self.errorMessage = "No access key available"
            }
            return
        }
        
        let progress = UploadProgress(fileName: name, progress: 0.0)
        
        DispatchQueue.main.async {
            self.uploadProgress.append(progress)
        }
        
        do {
            let encryptedData = try cryptoService.encryptData(data, publicKey: accessKey.publicKey)
            let keyHash = cryptoService.hashAccessKey(accessKey.keyId)
            
            for i in 0..<10 {
                try? await Task.sleep(nanoseconds: 500_000_000)
                
                DispatchQueue.main.async {
                    if let index = self.uploadProgress.firstIndex(where: { $0.fileName == name }) {
                        self.uploadProgress[index].progress = Double(i + 1) / 10.0
                    }
                }
            }
            
            let expiresAt = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            
            let newFile = ExchangeFile(
                id: UUID().uuidString,
                name: name,
                size: Int64(encryptedData.count),
                mimeType: mimeType,
                uploadedAt: Date(),
                expiresAt: expiresAt,
                accessHash: keyHash,
                downloadCount: 0,
                maxDownloads: -1,
                encryptedData: encryptedData
            )
            
            DispatchQueue.main.async {
                self.exchangeFiles.insert(newFile, at: 0)
                
                if let index = self.uploadProgress.firstIndex(where: { $0.fileName == name }) {
                    self.uploadProgress[index].isComplete = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.uploadProgress.removeAll { $0.fileName == name }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Encryption failed"
            }
        }
    }
    
    func deleteFile(_ fileId: String) async {
        guard currentAccessKey != nil else {
            DispatchQueue.main.async {
                self.errorMessage = "No access key available"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.exchangeFiles.removeAll { $0.id == fileId }
        }
    }
    
    func setCurrentAccessKey(_ key: AccessKey) {
        currentAccessKey = key
    }
}

enum StorageError: Error {
    case invalidQRCode
    case noAccessKey
}
