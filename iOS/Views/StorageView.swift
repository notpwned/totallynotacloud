import SwiftUI

struct StorageView: View {
    @EnvironmentObject var storageService: StorageService
    
    var fileCount: Int {
        storageService.files.filter { !$0.isDirectory }.count
    }
    
    var folderCount: Int {
        storageService.files.filter { $0.isDirectory }.count
    }
    
    var totalSize: Int64 {
        storageService.files.reduce(0) { $0 + $1.size }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Storage").font(.system(size: 28, weight: .bold)).foregroundColor(AppColors.textPrimary)
                        }
                        Spacer()
                    }
                    .padding(20)
                    .background(AppColors.surface)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Total Size").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary)
                                        Text(formatBytes(totalSize)).font(.system(size: 24, weight: .bold, design: .monospaced)).foregroundColor(AppColors.textPrimary)
                                    }
                                    Spacer()
                                    Image(systemName: "square.grid.2x2").font(.system(size: 32, weight: .light)).foregroundColor(AppColors.textTertiary)
                                }
                                .padding(16)
                                .background(AppColors.surface)
                                .cornerRadius(12)
                            }
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Files").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary)
                                        Text("\(fileCount)").font(.system(size: 18, weight: .semibold)).foregroundColor(AppColors.textPrimary)
                                    }
                                    Spacer()
                                    Image(systemName: "doc.fill").font(.system(size: 24, weight: .regular)).foregroundColor(AppColors.textTertiary)
                                }
                                .padding(12)
                                .background(AppColors.surface)
                                .cornerRadius(8)
                                
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Folders").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary)
                                        Text("\(folderCount)").font(.system(size: 18, weight: .semibold)).foregroundColor(AppColors.textPrimary)
                                    }
                                    Spacer()
                                    Image(systemName: "folder.fill").font(.system(size: 24, weight: .regular)).foregroundColor(AppColors.textTertiary)
                                }
                                .padding(12)
                                .background(AppColors.surface)
                                .cornerRadius(8)
                            }
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lock.fill").font(.system(size: 14)).foregroundColor(AppColors.textSecondary)
                                    Text("All files encrypted end-to-end").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary)
                                    Spacer()
                                }
                                .padding(12)
                                .background(AppColors.surface)
                                .cornerRadius(8)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "eye.slash.fill").font(.system(size: 14)).foregroundColor(AppColors.textSecondary)
                                    Text("Server cannot access your data").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary)
                                    Spacer()
                                }
                                .padding(12)
                                .background(AppColors.surface)
                                .cornerRadius(8)
                            }
                        }
                        .padding(20)
                    }
                    .background(AppColors.background)
                }
            }
        }
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview {
    StorageView().environmentObject(StorageService())
}
