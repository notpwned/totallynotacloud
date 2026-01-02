import SwiftUI

struct FilesView: View {
    @EnvironmentObject var storageService: StorageService
    @State private var showCreateFolder = false
    @State private var newFolderName = ""
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Files")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("\(storageService.files.count) items")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button(action: { showCreateFolder = true }) {
                            Label("New Folder", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.accentBlue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                if storageService.files.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cloud.slash")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("No Files")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(storageService.files) { file in
                                FileRowView(file: file)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            Task {
                                                await storageService.deleteFile(file)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                }
                
                if !storageService.uploadProgress.isEmpty {
                    VStack(spacing: 8) {
                        Divider()
                            .background(AppColors.divider)
                        
                        ForEach(storageService.uploadProgress) { progress in
                            VStack(spacing: 4) {
                                HStack {
                                    Text(progress.fileName)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    if progress.isComplete {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.success)
                                    }
                                }
                                
                                ProgressView(value: progress.progress)
                                    .tint(AppColors.accentBlue)
                            }
                        }
                        
                        Divider()
                            .background(AppColors.divider)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
        .onAppear {
            Task {
                await storageService.loadFiles()
            }
        }
        .alert("New Folder", isPresented: $showCreateFolder) {
            TextField("Folder name", text: $newFolderName)
            Button("Cancel", role: .cancel) {}
            Button("Create") {
                Task {
                    await storageService.createFolder(name: newFolderName)
                    newFolderName = ""
                }
            }
        }
    }
}

struct FileRowView: View {
    let file: CloudFile
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.fileIcon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.accentBlue)
                .frame(width: 40, height: 40)
                .background(AppColors.surface)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(file.formattedSize)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.surface)
        .cornerRadius(8)
    }
}

#Preview {
    FilesView()
        .environmentObject(StorageService())
}
