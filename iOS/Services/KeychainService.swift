import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private let keychainService = "com.totallynotacloud.keys"
    
    func saveAccessKey(_ key: AccessKey) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key.keyId,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    func retrieveAccessKey(keyId: String) throws -> AccessKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keyId,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.retrieveFailed
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(AccessKey.self, from: data)
    }
    
    func getAllAccessKeys() throws -> [AccessKey] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let items = result as? [[String: Any]] else {
            return []
        }
        
        var keys: [AccessKey] = []
        let decoder = JSONDecoder()
        
        for item in items {
            if let data = item[kSecValueData as String] as? Data {
                if let key = try? decoder.decode(AccessKey.self, from: data) {
                    keys.append(key)
                }
            }
        }
        
        return keys
    }
    
    func deleteAccessKey(keyId: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keyId
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed
        }
    }
}

enum KeychainError: Error {
    case saveFailed
    case retrieveFailed
    case deleteFailed
}
