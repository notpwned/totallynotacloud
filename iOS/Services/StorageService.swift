import Foundation
import Combine

class StorageService: ObservableObject {
    @Published var files: [CloudFile] = []
    @Published var currentFolder: CloudFile?
    @Published var isLoading = false
    @Published var uploadProgress: [UploadProgress] = []
    @Published var errorMessage: String?
    
    private let apiBaseURL = "https://api.totallynotacloud.local"
    private let cryptoService = CryptoService.shared
    private var currentAccessKey: AccessKey?
    
    init() {
        loadMockFiles()
    }
    
    func generateNewAccessKey() throws -> (key: AccessKey, qrCode: String) {
        let keyId = UUID().uuidString
        let accessKey = cryptoService.generateAccessKey()
        let keyHash = cryptoService.hashAccessKey(accessKey)
        
        let (publicKey, privateKey) = try cryptoService.generateKeyPair()
        
        let accessKeyModel = AccessKey(
            keyId: keyId,
            publicKey: publicKey,
            privateKey: privateKey,
            createdAt: Date(),
            permissions: ["read", "write", "delete"]
        )
        
        try cryptoService.saveAccessKeyToKeychain(accessKeyModel)
        self.currentAccessKey = accessKeyModel
        
        let qrData = "\(keyId):\(accessKey)"
        return (accessKeyModel, qrData)
    }
    
    func importAccessKeyFromQR(_ qrData: String) throws {
        let components = qrData.split(separator: ":")
        guard components.count == 2 else {
            throw StorageError.invalidQRCode
        }
        
        let keyId = String(components[0])
        let accessKey = try cryptoService.retrieveAccessKeyFromKeychain(keyId: keyId)
        self.currentAccessKey = accessKey
    }
    
    func loadFiles(folderId: String? = nil) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        guard let _ = currentAccessKey else {
            DispatchQueue.main.async {
                self.errorMessage = "No access key available"
                self.isLoading = false
            }
            return
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        DispatchQueue.main.async {
            if self.files.isEmpty {
                self.loadMockFiles()
            }
            self.isLoading = false
        }
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
            
            let newFile = CloudFile(
                id: UUID().uuidString,
                name: name,
                size: Int64(encryptedData.count),
                mimeType: mimeType,
                uploadedAt: Date(),
                updatedAt: Date(),
                accessKeyHash: keyHash
            )
            
            DispatchQueue.main.async {
                self.files.insert(newFile, at: 0)
                
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
    
    func deleteFile(_ file: CloudFile) async {
        guard currentAccessKey != nil else {
            DispatchQueue.main.async {
                self.errorMessage = "No access key available"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.files.removeAll { $0.id == file.id }
        }
    }
    
    func downloadFile(_ file: CloudFile) async -> Data? {
        guard let accessKey = currentAccessKey else {
            DispatchQueue.main.async {
                self.errorMessage = "No access key available"
            }
            return nil
        }
        
        do {
            let encryptedData = Data()
            let decryptedData = try cryptoService.decryptData(encryptedData, privateKey: accessKey.privateKey)
            return decryptedData
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Decryption failed"
            }
            return nil
        }
    }
    
    func renameFile(_ file: CloudFile, newName: String) async {
        if let index = files.firstIndex(where: { $0.id == file.id }) {
            DispatchQueue.main.async {
                var updatedFile = self.files[index]
                updatedFile.name = newName
                updatedFile.updatedAt = Date()
                self.files[index] = updatedFile
            }
        }
    }
    
    func createFolder(name: String) async {
        guard let accessKey = currentAccessKey else {
            DispatchQueue.main.async {
                self.errorMessage = "No access key available"
            }
            return
        }
        
        let keyHash = cryptoService.hashAccessKey(accessKey.keyId)
        
        let newFolder = CloudFile(
            id: UUID().uuidString,
            name: name,
            size: 0,
            mimeType: "application/x-folder",
            uploadedAt: Date(),
            updatedAt: Date(),
            isDirectory: true,
            accessKeyHash: keyHash
        )
        
        DispatchQueue.main.async {
            self.files.insert(newFolder, at: 0)
        }
    }
    
    func setCurrentAccessKey(_ key: AccessKey) {
        self.currentAccessKey = key
    }
    
    private func loadMockFiles() {
        let mockKeyHash = "mock-hash"
        
        let mockFiles: [CloudFile] = [
            CloudFile(
                id: "1",
                name: "Documents",
                size: 0,
                mimeType: "application/x-folder",
                uploadedAt: Date(timeIntervalSinceNow: -86400),
                updatedAt: Date(timeIntervalSinceNow: -3600),
                isDirectory: true,
                accessKeyHash: mockKeyHash
            ),
            CloudFile(
                id: "2",
                name: "Photos",
                size: 0,
                mimeType: "application/x-folder",
                uploadedAt: Date(timeIntervalSinceNow: -172800),
                updatedAt: Date(timeIntervalSinceNow: -7200),
                isDirectory: true,
                accessKeyHash: mockKeyHash
            )
        ]
        
        DispatchQueue.main.async {
            self.files = mockFiles
        }
    }
}

enum StorageError: Error {
    case invalidQRCode
    case noAccessKey
}
