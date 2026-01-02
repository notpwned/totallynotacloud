import SwiftUI

struct FilesView: View {
    @EnvironmentObject var storageService: StorageService
    @State private var showUploadOptions = false
    @State private var showFilePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Exchange").font(.system(size: 28, weight: .bold)).foregroundColor(AppColors.textPrimary)
                            Text("Share encrypted files").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Button(action: { showUploadOptions = true }) {
                            Image(systemName: "plus.circle.fill").font(.system(size: 24)).foregroundColor(AppColors.accent)
                        }
                    }
                    .padding(20)
                    .background(AppColors.surface)
                    
                    if storageService.exchangeFiles.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "arrow.up.arrow.down.circle").font(.system(size: 56)).foregroundColor(AppColors.textTertiary)
                            Text("No files yet").font(.system(size: 16, weight: .semibold)).foregroundColor(AppColors.textSecondary)
                            Text("Upload a file to get started").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textTertiary)
                        }
                        .frame(maxHeight: .infinity)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.background)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(storageService.exchangeFiles) { file in
                                    FileExchangeRow(file: file)
                                }
                            }
                            .padding(16)
                        }
                        .background(AppColors.background)
                    }
                }
            }
            .sheet(isPresented: $showUploadOptions) {
                VStack(spacing: 12) {
                    HStack {
                        Text("Upload File").font(.system(size: 18, weight: .semibold)).foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Button(action: { showUploadOptions = false }) {
                            Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundColor(AppColors.textTertiary)
                        }
                    }
                    .padding(16)
                    
                    VStack(spacing: 12) {
                        Button(action: { showFilePicker = true; showUploadOptions = false }) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.badge.plus").font(.system(size: 16)).foregroundColor(AppColors.textPrimary)
                                Text("From Files").font(.system(size: 14, weight: .regular)).foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(AppColors.textTertiary)
                            }
                            .padding(12)
                            .background(AppColors.surface)
                            .cornerRadius(8)
                        }
                        
                        Button(action: {}) {
                            HStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus").font(.system(size: 16)).foregroundColor(AppColors.textPrimary)
                                Text("From Photos").font(.system(size: 14, weight: .regular)).foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(AppColors.textTertiary)
                            }
                            .padding(12)
                            .background(AppColors.surface)
                            .cornerRadius(8)
                        }
                    }
                    .padding(16)
                    
                    Spacer()
                    
                    Button(action: { showUploadOptions = false }) {
                        Text("Cancel").frame(maxWidth: .infinity).frame(height: 44).background(AppColors.surfaceLight).foregroundColor(AppColors.textPrimary).font(.system(size: 14, weight: .semibold)).cornerRadius(8)
                    }
                    .padding(16)
                }
                .background(AppColors.background)
                .presentationDetents([.height(300)])
                .presentationCornerRadius(16)
            }
        }
    }
}

struct FileExchangeRow: View {
    let file: ExchangeFile
    @State private var showDetails = false
    
    var body: some View {
        Button(action: { showDetails = true }) {
            HStack(spacing: 12) {
                Image(systemName: "doc.fill").font(.system(size: 16)).foregroundColor(AppColors.accent)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(file.name).font(.system(size: 14, weight: .semibold)).foregroundColor(AppColors.textPrimary).lineLimit(1)
                    HStack(spacing: 8) {
                        Text(formatFileSize(file.size)).font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary)
                        Text("\(formatTimeLeft(file.expiresAt))").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textTertiary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "link").font(.system(size: 12)).foregroundColor(AppColors.accent)
                    Text("\(file.downloadCount)").font(.system(size: 11, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textTertiary)
                }
            }
            .padding(12)
            .background(AppColors.surface)
            .cornerRadius(8)
        }
        .sheet(isPresented: $showDetails) {
            FileDetailsSheet(file: file)
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatTimeLeft(_ date: Date) -> String {
        let remaining = date.timeIntervalSinceNow
        if remaining < 0 {
            return "Expired"
        }
        let days = Int(remaining / 86400)
        if days > 0 {
            return "\(days)d left"
        }
        let hours = Int(remaining / 3600)
        return "\(hours)h left"
    }
}

struct FileDetailsSheet: View {
    let file: ExchangeFile
    @State private var copied = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("File Share Link").font(.system(size: 18, weight: .semibold)).foregroundColor(AppColors.textPrimary)
                Spacer()
                Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundColor(AppColors.textTertiary)
            }
            .padding(16)
            
            VStack(spacing: 12) {
                Text(file.name).font(.system(size: 14, weight: .semibold)).foregroundColor(AppColors.textPrimary).frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 12) {
                    Text("tcd://exchange/\(file.id)").font(.system(size: 12, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textSecondary).lineLimit(1)
                    Button(action: {
                        UIPasteboard.general.string = "tcd://exchange/\(file.id)"
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copied = false
                        }
                    }) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc").font(.system(size: 12)).foregroundColor(AppColors.accent)
                    }
                }
                .padding(12)
                .background(AppColors.surface)
                .cornerRadius(6)
                
                Divider().background(AppColors.divider)
                
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(label: "Size", value: formatFileSize(file.size))
                    InfoRow(label: "Downloads", value: file.maxDownloads < 0 ? "\(file.downloadCount)" : "\(file.downloadCount)/\(file.maxDownloads)")
                    InfoRow(label: "Uploaded", value: formatDate(file.uploadedAt))
                    InfoRow(label: "Expires", value: formatDate(file.expiresAt))
                }
            }
            .padding(16)
            .background(AppColors.surface)
            .cornerRadius(8)
            
            Spacer()
            
            Button(action: {}) {
                HStack {
                    Image(systemName: "trash.fill").font(.system(size: 14))
                    Text("Delete")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(white: 0.3))
                .foregroundColor(AppColors.textPrimary)
                .font(.system(size: 14, weight: .semibold))
                .cornerRadius(8)
            }
            .padding(16)
        }
        .background(AppColors.background)
        .presentationDetents([.height(500)])
        .presentationCornerRadius(16)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label).font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value).font(.system(size: 12, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textPrimary)
        }
    }
}

#Preview {
    FilesView().environmentObject(StorageService())
}
