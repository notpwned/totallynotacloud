import SwiftUI

struct StorageView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var storageService: StorageService
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            if let user = authService.user {
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Storage")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Manage your cloud space")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            VStack(spacing: 12) {
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(AppColors.surface)
                                        
                                        Capsule()
                                            .fill(AppColors.accentBlue)
                                            .frame(width: geometry.size.width * CGFloat(user.storageUsagePercent / 100.0))
                                    }
                                    .frame(height: 12)
                                }
                                .frame(height: 12)
                                
                                HStack {
                                    Text(user.formattedStorageUsed)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("of")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    Text(user.formattedStorageLimit)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(16)
                            .background(AppColors.surface)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            StatisticRow(
                                title: "Remaining",
                                value: ByteCountFormatter().string(fromByteCount: user.remainingStorage),
                                icon: "arrow.down.circle.fill"
                            )
                            
                            StatisticRow(
                                title: "Files",
                                value: String(storageService.files.count),
                                icon: "doc.fill"
                            )
                            
                            StatisticRow(
                                title: "Folders",
                                value: String(storageService.files.filter { $0.isDirectory }.count),
                                icon: "folder.fill"
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tips")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            TipView(
                                icon: "trash.fill",
                                title: "Clean up old files",
                                description: "Remove unused documents to free up space"
                            )
                            
                            TipView(
                                icon: "photo.fill",
                                title: "Compress images",
                                description: "Use compressed formats for photos"
                            )
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.accentBlue)
                .frame(width: 40, height: 40)
                .background(AppColors.surfaceLight)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.surface)
        .cornerRadius(8)
    }
}

struct TipView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.accentBlue)
                .frame(width: 32, height: 32)
                .background(AppColors.surfaceLight)
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    StorageView()
        .environmentObject(AuthService())
        .environmentObject(StorageService())
}
