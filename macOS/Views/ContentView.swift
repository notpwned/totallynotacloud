import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var storageService: StorageService
    @Binding var selectedTab: Int
    @State private var isDropping = false
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
                .environmentObject(authService)
                .environmentObject(storageService)
        } detail: {
            switch selectedTab {
            case 0:
                FilesDetailView()
                    .environmentObject(storageService)
            case 1:
                StorageDetailView()
                    .environmentObject(authService)
                    .environmentObject(storageService)
            case 2:
                ProfileDetailView()
                    .environmentObject(authService)
            default:
                Text("Select an option")
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onDrop(of: ["public.file-url"], isTargeted: $isDropping) { providers in
            handleDrop(providers: providers)
            return true
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
                if let url = item as? URL {
                    Task {
                        do {
                            let fileData = try Data(contentsOf: url)
                            await storageService.uploadFile(
                                data: fileData,
                                name: url.lastPathComponent,
                                mimeType: getMimeType(for: url)
                            )
                        } catch {
                            print("Error reading file: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    private func getMimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        let mimeTypes: [String: String] = [
            "pdf": "application/pdf",
            "txt": "text/plain",
            "doc": "application/msword",
            "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "xls": "application/vnd.ms-excel",
            "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "jpg": "image/jpeg",
            "jpeg": "image/jpeg",
            "png": "image/png",
            "gif": "image/gif",
            "zip": "application/zip",
            "mov": "video/quicktime",
            "mp4": "video/mp4"
        ]
        return mimeTypes[pathExtension] ?? "application/octet-stream"
    }
}

struct SidebarView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var storageService: StorageService
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.accentBlue)
                
                Text("totallynotacloud")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.surface)
            
            Divider()
                .background(AppColors.divider)
            
            List(selection: $selectedTab) {
                NavigationLink(value: 0) {
                    HStack(spacing: 12) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.accentBlue)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Files")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("\(storageService.files.count) items")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                }
                .tag(0)
                
                NavigationLink(value: 1) {
                    HStack(spacing: 12) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.accentBlue)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Storage")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            if let user = authService.user {
                                Text(user.formattedStorageUsed)
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .tag(1)
                
                NavigationLink(value: 2) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.accentBlue)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Profile")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            if let user = authService.user {
                                Text(user.username)
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .tag(2)
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            
            Divider()
                .background(AppColors.divider)
            
            HStack(spacing: 12) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.accentBlue)
                
                Menu {
                    Button(role: .destructive) {
                        authService.logout()
                    } label: {
                        Label("Sign Out", systemImage: "arrow.backward.circle.fill")
                    }
                } label: {
                    Text("Menu")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(minWidth: 200, maxWidth: 280)
        .background(AppColors.background)
    }
}

struct FilesDetailView: View {
    @EnvironmentObject var storageService: StorageService
    @State private var showCreateFolder = false
    @State private var newFolderName = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Files")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { showCreateFolder = true }) {
                        Label("New Folder", systemImage: "folder.badge.plus")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(16)
            .background(AppColors.surface)
            
            Divider()
                .background(AppColors.divider)
            
            if storageService.files.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cloud.slash")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("No Files")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Drag and drop files here")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                        .opacity(0.7)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 1) {
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
                }
            }
        }
        .background(AppColors.background)
        .onAppear {
            Task {
                await storageService.loadFiles()
            }
        }
    }
}

struct FileRowView: View {
    let file: CloudFile
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.fileIcon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.accentBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(file.formattedSize)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Text(file.uploadedAt.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppColors.surface)
    }
}

struct StorageDetailView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var storageService: StorageService
    
    var body: some View {
        if let user = authService.user {
            VStack(alignment: .leading, spacing: 20) {
                Text("Storage Usage")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                VStack(spacing: 12) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppColors.surface)
                            
                            Capsule()
                                .fill(AppColors.accentBlue)
                                .frame(width: geometry.size.width * CGFloat(user.storageUsagePercent / 100.0))
                        }
                        .frame(height: 16)
                    }
                    .frame(height: 16)
                    
                    HStack {
                        Text(user.formattedStorageUsed)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("of")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(user.formattedStorageLimit)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f%%", user.storageUsagePercent))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.accentBlue)
                    }
                }
                .padding(16)
                .background(AppColors.surface)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding(16)
        }
    }
}

struct ProfileDetailView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showLogoutAlert = false
    
    var body: some View {
        if let user = authService.user {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(AppColors.accentBlue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.username)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(user.email)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(AppColors.success)
                                .frame(width: 6, height: 6)
                            
                            Text("Online")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.success)
                        }
                        .padding(.top, 4)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Account Info")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    HStack {
                        Text("Member Since")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Text(user.createdAt.formatted(date: .long, time: .omitted))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(12)
                    .background(AppColors.surface)
                    .cornerRadius(6)
                }
                
                Spacer()
                
                Button(role: .destructive, action: { showLogoutAlert = true }) {
                    HStack {
                        Image(systemName: "arrow.backward.circle.fill")
                        Text("Sign Out")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
            .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authService.logout()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

#Preview {
    ContentView(selectedTab: .constant(0))
        .environmentObject(AuthService())
        .environmentObject(StorageService())
}
