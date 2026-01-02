import SwiftUI

@main
struct totallynotacloudApp: App {
    @StateObject private var storageService = StorageService()
    @State private var hasAccessKey = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if hasAccessKey {
                    MainTabView()
                        .environmentObject(storageService)
                } else {
                    AuthView()
                        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AccessKeyCreated"))) { _ in
                            hasAccessKey = true
                        }
                }
            }
        }
    }
}
