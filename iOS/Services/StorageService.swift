import Foundation
import Combine

/// Сервис для управления файлами и хранилищем
class StorageService: ObservableObject {
    @Published var files: [CloudFile] = []
    @Published var currentFolder: CloudFile?
    @Published var isLoading = false
    @Published var uploadProgress: [UploadProgress] = []
    @Published var errorMessage: String?
    
    private let apiBaseURL = "https://api.totallynotacloud.local"
    
    init() {
        loadMockFiles()
    }
    
    func loadFiles(folderId: String? = nil) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
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
        let progress = UploadProgress(fileName: name, progress: 0.0)
        
        DispatchQueue.main.async {
            self.uploadProgress.append(progress)
        }
        
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
            size: Int64(data.count),
            mimeType: mimeType,
            uploadedAt: Date(),
            updatedAt: Date()
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
    }
    
    func deleteFile(_ file: CloudFile) async {
        DispatchQueue.main.async {
            self.files.removeAll { $0.id == file.id }
        }
    }
    
    func renameFile(_ file: CloudFile, newName: String) async {
        if let index = files.firstIndex(where: { $0.id == file.id }) {
            DispatchQueue.main.async {
                var updatedFile = self.files[index]
                updatedFile.updatedAt = Date()
                self.files[index] = updatedFile
            }
        }
    }
    
    func createFolder(name: String) async {
        let newFolder = CloudFile(
            id: UUID().uuidString,
            name: name,
            size: 0,
            mimeType: "application/x-folder",
            uploadedAt: Date(),
            updatedAt: Date(),
            isDirectory: true
        )
        
        DispatchQueue.main.async {
            self.files.insert(newFolder, at: 0)
        }
    }
    
    private func loadMockFiles() {
        let mockFiles: [CloudFile] = [
            CloudFile(
                id: "1",
                name: "Documents",
                size: 0,
                mimeType: "application/x-folder",
                uploadedAt: Date(timeIntervalSinceNow: -86400),
                updatedAt: Date(timeIntervalSinceNow: -3600),
                isDirectory: true
            ),
            CloudFile(
                id: "2",
                name: "Photos",
                size: 0,
                mimeType: "application/x-folder",
                uploadedAt: Date(timeIntervalSinceNow: -172800),
                updatedAt: Date(timeIntervalSinceNow: -7200),
                isDirectory: true
            ),
            CloudFile(
                id: "3",
                name: "Project.pdf",
                size: 2_500_000,
                mimeType: "application/pdf",
                uploadedAt: Date(timeIntervalSinceNow: -259200),
                updatedAt: Date(timeIntervalSinceNow: -259200)
            ),
            CloudFile(
                id: "4",
                name: "Presentation.key",
                size: 15_000_000,
                mimeType: "application/x-iwork-presentation",
                uploadedAt: Date(timeIntervalSinceNow: -604800),
                updatedAt: Date(timeIntervalSinceNow: -604800)
            ),
            CloudFile(
                id: "5",
                name: "Screenshot.png",
                size: 3_500_000,
                mimeType: "image/png",
                uploadedAt: Date(timeIntervalSinceNow: -1209600),
                updatedAt: Date(timeIntervalSinceNow: -1209600)
            )
        ]
        
        DispatchQueue.main.async {
            self.files = mockFiles
        }
    }
}
