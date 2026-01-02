import Foundation
import Combine

/// Сервис для управления аутентификацией
class AuthService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authToken: String? {
        get {
            UserDefaults.standard.string(forKey: "authToken")
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: "authToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
        }
    }
    
    private let apiBaseURL = "https://api.totallynotacloud.local" // Заменить на реальный URL
    
    init() {
        checkAuthStatus()
    }
    
    /// Проверка статуса аутентификации
    func checkAuthStatus() {
        if let token = authToken {
            isAuthenticated = true
            fetchUserProfile()
        } else {
            isAuthenticated = false
            user = nil
        }
    }
    
    /// Вход пользователя (mock версия)
    func login(email: String, password: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 сек
        
        DispatchQueue.main.async {
            self.user = User(
                id: UUID().uuidString,
                email: email,
                username: email.split(separator: "@").first.map(String.init) ?? email,
                createdAt: Date()
            )
            self.authToken = "mock_token_" + UUID().uuidString
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    /// Регистрация пользователя (mock версия)
    func register(email: String, username: String, password: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 сек
        
        DispatchQueue.main.async {
            self.user = User(
                id: UUID().uuidString,
                email: email,
                username: username,
                createdAt: Date()
            )
            self.authToken = "mock_token_" + UUID().uuidString
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    /// Выход пользователя
    func logout() {
        DispatchQueue.main.async {
            self.user = nil
            self.authToken = nil
            self.isAuthenticated = false
            self.errorMessage = nil
        }
    }
    
    /// Загрузка профиля пользователя
    private func fetchUserProfile() {
        if user == nil {
            user = User(
                id: UUID().uuidString,
                email: "user@example.com",
                username: "user",
                createdAt: Date()
            )
        }
    }
}
