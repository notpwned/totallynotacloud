import SwiftUI

@main
struct totallynotacloudApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var storageService = StorageService()
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
                    .environmentObject(storageService)
            } else {
                AuthView()
                    .environmentObject(authService)
            }
        }
    }
}
