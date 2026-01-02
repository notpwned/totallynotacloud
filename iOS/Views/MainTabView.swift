import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var storageService: StorageService
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                FilesView()
                    .tabItem {
                        Image(systemName: "folder.fill")
                        Text("Files")
                    }
                    .tag(0)
                
                StorageView()
                    .tabItem {
                        Image(systemName: "chart.pie.fill")
                        Text("Storage")
                    }
                    .tag(1)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(2)
            }
            .tint(AppColors.accentBlue)
            .onAppear {
                configureTabBar()
            }
        }
    }
    
    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(AppColors.surface)
        appearance.backgroundEffect = nil
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textSecondary)]
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppColors.accentBlue)]
        
        appearance.stackedLayoutAppearance = itemAppearance
        UITabBar.appearance().standardAppearance = appearance
    }
}
