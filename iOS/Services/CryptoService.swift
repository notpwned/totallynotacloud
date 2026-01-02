import Foundation
import CommonCrypto

class CryptoService {
    static let shared = CryptoService()
    
    private let keychainService = KeychainService.shared
    
    func generateKeyPair() throws -> (publicKey: String, privateKey: String) {
        let keySize = 2048
        var publicKeyRef: SecKey?
        var privateKeyRef: SecKey?
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: keySize,
            kSecPublicKeyAttrs as String: [
                kSecAttrIsPermanent as String: false
            ] as [String: Any],
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false
            ] as [String: Any]
        ]
        
        let status = SecKeyGeneratePair(attributes as CFDictionary, &publicKeyRef, &privateKeyRef)
        guard status == errSecSuccess, let pub = publicKeyRef, let priv = privateKeyRef else {
            throw CryptoError.keyGenerationFailed
        }
        
        let publicKeyData = SecKeyCopyExternalRepresentation(pub, nil) as Data? ?? Data()
        let privateKeyData = SecKeyCopyExternalRepresentation(priv, nil) as Data? ?? Data()
        
        let publicKeyString = publicKeyData.base64EncodedString()
        let privateKeyString = privateKeyData.base64EncodedString()
        
        return (publicKeyString, privateKeyString)
    }
    
    func encryptData(_ data: Data, publicKey: String) throws -> Data {
        let keyData = Data(base64Encoded: publicKey) ?? Data()
        guard let key = SecKeyCreateWithData(keyData as CFData, [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic
        ] as CFDictionary, nil) else {
            throw CryptoError.invalidKey
        }
        
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(key, .rsaEncryptionOAEPSHA256, data as CFData, &error) as Data? else {
            throw CryptoError.encryptionFailed
        }
        
        return encryptedData
    }
    
    func decryptData(_ encryptedData: Data, privateKey: String) throws -> Data {
        let keyData = Data(base64Encoded: privateKey) ?? Data()
        guard let key = SecKeyCreateWithData(keyData as CFData, [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ] as CFDictionary, nil) else {
            throw CryptoError.invalidKey
        }
        
        var error: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(key, .rsaEncryptionOAEPSHA256, encryptedData as CFData, &error) as Data? else {
            throw CryptoError.decryptionFailed
        }
        
        return decryptedData
    }
    
    func hashAccessKey(_ key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let data = key.data(using: .utf8)!
        _ = data.withUnsafeBytes { buffer in
            CC_SHA256(buffer.baseAddress!, CC_LONG(data.count), &digest)
        }
        return Data(digest).base64EncodedString()
    }
    
    func generateAccessKey(length: Int = 32) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}

enum CryptoError: Error {
    case keyGenerationFailed
    case invalidKey
    case encryptionFailed
    case decryptionFailed
    case keychainError
}
