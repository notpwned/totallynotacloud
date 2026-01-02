import SwiftUI

struct FilesView: View {
    @EnvironmentObject var storageService: StorageService
    @State private var showingCreateFolder = false
    @State private var folderName = ""
    @State private var selectedFile: CloudFile?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Files").font(.system(size: 28, weight: .bold)).foregroundColor(AppColors.textPrimary)
                        }
                        Spacer()
                        Button(action: { showingCreateFolder = true }) {
                            Image(systemName: "folder.badge.plus").font(.system(size: 18, weight: .semibold)).foregroundColor(AppColors.accent)
                        }
                    }
                    .padding(20)
                    .background(AppColors.surface)
                    
                    if storageService.files.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "folder.circle").font(.system(size: 48, weight: .light)).foregroundColor(AppColors.textTertiary)
                            Text("No files yet").font(.system(size: 14, weight: .regular)).foregroundColor(AppColors.textSecondary)
                            Text("Create folder or upload files").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppColors.background)
                    } else {
                        List {
                            ForEach(storageService.files) { file in
                                FileRowView(file: file)
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedFile = file
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(AppColors.background)
                    }
                    
                    if !storageService.uploadProgress.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(storageService.uploadProgress) { progress in
                                VStack(spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.up").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary)
                                        Text(progress.fileName).font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textPrimary).lineLimit(1)
                                        Spacer()
                                        Text(String(format: "%.0f%%", progress.progress * 100)).font(.system(size: 11, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textTertiary)
                                    }
                                    ProgressView(value: progress.progress).tint(AppColors.accent)
                                }
                            }
                        }
                        .padding(16)
                        .background(AppColors.surface)
                    }
                }
            }
            .sheet(isPresented: $showingCreateFolder) {
                VStack(spacing: 20) {
                    Text("New Folder").font(.system(size: 18, weight: .semibold)).foregroundColor(AppColors.textPrimary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Folder name").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary)
                        TextField("Enter name", text: $folderName).font(.system(size: 14, weight: .regular)).foregroundColor(AppColors.textPrimary).padding(12).background(AppColors.surface).cornerRadius(8)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: { showingCreateFolder = false }) {
                            Text("Cancel").frame(maxWidth: .infinity).frame(height: 44).background(AppColors.surface).foregroundColor(AppColors.textPrimary).font(.system(size: 14, weight: .semibold)).cornerRadius(8)
                        }
                        Button(action: {
                            Task {
                                await storageService.createFolder(name: folderName)
                                folderName = ""
                                showingCreateFolder = false
                            }
                        }) {
                            Text("Create").frame(maxWidth: .infinity).frame(height: 44).background(AppColors.accent).foregroundColor(AppColors.background).font(.system(size: 14, weight: .semibold)).cornerRadius(8)
                        }
                    }
                }
                .padding(24)
                .background(AppColors.background)
            }
        }
    }
}

struct FileRowView: View {
    @EnvironmentObject var storageService: StorageService
    let file: CloudFile
    @State private var showingContextMenu = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.fileIcon).font(.system(size: 18, weight: .semibold)).foregroundColor(AppColors.textPrimary).frame(width: 32, alignment: .center)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name).font(.system(size: 14, weight: .regular)).foregroundColor(AppColors.textPrimary).lineLimit(1)
                HStack(spacing: 8) {
                    if !file.isDirectory {
                        Text(file.formattedSize).font(.system(size: 11, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textTertiary)
                    }
                    Text(file.uploadedAt, style: .date).font(.system(size: 11, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textTertiary)
                }
            }
            
            Spacer()
            
            Menu {
                Button(role: .destructive, action: {
                    Task {
                        await storageService.deleteFile(file)
                    }
                }) {
                    HStack {
                        Text("Delete")
                        Image(systemName: "trash.fill")
                    }
                }
            } label: {
                Image(systemName: "ellipsis").font(.system(size: 14, weight: .semibold)).foregroundColor(AppColors.textTertiary).frame(width: 32, alignment: .center)
            }
        }
        .padding(12)
        .background(AppColors.surface)
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

#Preview {
    FilesView().environmentObject(StorageService())
}
