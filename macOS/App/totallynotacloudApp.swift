import SwiftUI

@main
struct totallynotacloudApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var storageService = StorageService()
    @State private var selectedTab: Int = 0
    
    var body: some Scene {
        WindowGroup("totallynotacloud") {
            if authService.isAuthenticated {
                ContentView(selectedTab: $selectedTab)
                    .environmentObject(authService)
                    .environmentObject(storageService)
                    .frame(minWidth: 800, minHeight: 600)
            } else {
                AuthView()
                    .environmentObject(authService)
                    .frame(width: 500, height: 600)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizabilityContentSize()
    }
}
