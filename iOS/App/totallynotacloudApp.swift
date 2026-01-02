import SwiftUI

@main
struct totallynotacloudApp: App {
    @StateObject private var storageService = StorageService()
    @State private var isAuthenticated = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if isAuthenticated {
                    MainTabView()
                        .environmentObject(storageService)
                } else {
                    AuthView(isAuthenticated: $isAuthenticated)
                }
            }
        }
    }
}
