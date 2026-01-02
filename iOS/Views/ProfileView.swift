import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            if let user = authService.user {
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(AppColors.accentBlue)
                            
                            Text(user.username)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(user.email)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(AppColors.success)
                                    .frame(width: 8, height: 8)
                                
                                Text("Online")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.success)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        
                        VStack(spacing: 12) {
                            InfoCard(
                                icon: "calendar",
                                label: "Joined",
                                value: user.createdAt.formatted(date: .long, time: .omitted)
                            )
                            
                            InfoCard(
                                icon: "key.fill",
                                label: "User ID",
                                value: String(user.id.prefix(12)) + "..."
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            NavigationLink(destination: Text("Settings").foregroundColor(AppColors.textPrimary)) {
                                HStack {
                                    Image(systemName: "gear")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.accentBlue)
                                        .frame(width: 30)
                                    
                                    Text("Settings")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            
                            Divider()
                                .background(AppColors.divider)
                                .padding(.leading, 46)
                            
                            NavigationLink(destination: Text("Security").foregroundColor(AppColors.textPrimary)) {
                                HStack {
                                    Image(systemName: "shield.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.accentBlue)
                                        .frame(width: 30)
                                    
                                    Text("Security")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            
                            Divider()
                                .background(AppColors.divider)
                                .padding(.leading, 46)
                            
                            NavigationLink(destination: Text("Help").foregroundColor(AppColors.textPrimary)) {
                                HStack {
                                    Image(systemName: "questionmark.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.accentBlue)
                                        .frame(width: 30)
                                    
                                    Text("Help")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        Button(role: .destructive, action: { showLogoutAlert = true }) {
                            HStack {
                                Image(systemName: "arrow.backward.circle.fill")
                                    .font(.system(size: 16))
                                
                                Text("Sign Out")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppColors.error.opacity(0.15))
                            .foregroundColor(AppColors.error)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Profile")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
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

struct InfoCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.accentBlue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.surface)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthService())
    }
}
