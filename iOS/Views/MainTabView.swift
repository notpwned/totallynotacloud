import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var storageService: StorageService
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    FilesView()
                        .tabItem {
                            Label("Files", systemImage: "doc.text")
                        }
                        .tag(0)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(1)
                }
                .accentColor(AppColors.accent)
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var storageService: StorageService
    @State private var showExportKey = false
    @State private var privateKeyText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings").font(.system(size: 28, weight: .bold)).foregroundColor(AppColors.textPrimary)
                        }
                        Spacer()
                    }
                    .padding(20)
                    .background(AppColors.surface)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            VStack(spacing: 12) {
                                Text("Access Key").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary).frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button(action: { showExportKey = true }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "key.fill").font(.system(size: 16)).foregroundColor(AppColors.textPrimary)
                                        Text("Export Key").font(.system(size: 14, weight: .regular)).foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(AppColors.textTertiary)
                                    }
                                    .padding(12)
                                    .background(AppColors.surface)
                                    .cornerRadius(8)
                                }
                            }
                            
                            VStack(spacing: 12) {
                                Text("About").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary).frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Version").font(.system(size: 14, weight: .regular)).foregroundColor(AppColors.textSecondary)
                                        Spacer()
                                        Text("1.0.0").font(.system(size: 14, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textTertiary)
                                    }
                                    Divider().background(AppColors.divider)
                                    HStack {
                                        Text("Encryption").font(.system(size: 14, weight: .regular)).foregroundColor(AppColors.textSecondary)
                                        Spacer()
                                        Text("RSA-2048").font(.system(size: 14, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textTertiary)
                                    }
                                }
                                .padding(12)
                                .background(AppColors.surface)
                                .cornerRadius(8)
                            }
                            
                            VStack(spacing: 12) {
                                Text("Privacy").font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.textSecondary).frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lock.fill").font(.system(size: 12)).foregroundColor(AppColors.success)
                                        Text("Zero-knowledge architecture").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "eye.slash.fill").font(.system(size: 12)).foregroundColor(AppColors.success)
                                        Text("No user tracking").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "person.slash.fill").font(.system(size: 12)).foregroundColor(AppColors.success)
                                        Text("No accounts required").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary)
                                    }
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
            .sheet(isPresented: $showExportKey) {
                VStack(spacing: 16) {
                    HStack {
                        Text("Your Private Key").font(.system(size: 18, weight: .semibold)).foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Image(systemName: "xmark.circle.fill").font(.system(size: 20)).foregroundColor(AppColors.textTertiary)
                    }
                    .padding(16)
                    
                    Text("Never share this key. Store it safely.").font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary).frame(maxWidth: .infinity, alignment: .leading).padding(0).padding(.horizontal, 16)
                    
                    ScrollView {
                        Text("[Private key would be displayed here]").font(.system(size: 11, weight: .regular, design: .monospaced)).foregroundColor(AppColors.textPrimary).frame(maxWidth: .infinity, alignment: .leading).padding(12).background(AppColors.surface).cornerRadius(6).lineLimit(10)
                    }
                    .frame(height: 120)
                    .padding(.horizontal, 16)
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "doc.on.doc").font(.system(size: 14))
                            Text("Copy to Clipboard")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppColors.accent)
                        .foregroundColor(AppColors.background)
                        .font(.system(size: 14, weight: .semibold))
                        .cornerRadius(8)
                    }
                    .padding(16)
                    
                    Spacer()
                }
                .background(AppColors.background)
                .presentationDetents([.height(400)])
                .presentationCornerRadius(16)
            }
        }
    }
}

#Preview {
    MainTabView().environmentObject(StorageService())
}
