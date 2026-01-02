import Foundation

/// Модель пользователя
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    let createdAt: Date
    var storageUsed: Int64 = 0
    var storageLimit: Int64 = 10_737_418_240 // 10 GB по умолчанию
    
    /// Процент использованного хранилища
    var storageUsagePercent: Double {
        guard storageLimit > 0 else { return 0 }
        return Double(storageUsed) / Double(storageLimit) * 100
    }
    
    /// Оставшееся хранилище
    var remainingStorage: Int64 {
        max(0, storageLimit - storageUsed)
    }
    
    /// Форматированное использованное хранилище
    var formattedStorageUsed: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: storageUsed)
    }
    
    /// Форматированный лимит хранилища
    var formattedStorageLimit: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: storageLimit)
    }
}

/// Модель для входа пользователя
struct LoginRequest: Codable {
    let email: String
    let password: String
}

/// Модель для регистрации пользователя
struct RegisterRequest: Codable {
    let email: String
    let username: String
    let password: String
}

/// Модель для ответа с токеном
struct AuthResponse: Codable {
    let token: String
    let user: User
}
