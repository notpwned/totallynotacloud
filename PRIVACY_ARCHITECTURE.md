# Privacy and Encryption Architecture

## Zero-Knowledge Design

The entire application is built on zero-knowledge encryption principles. The server cannot decrypt, read, or understand any file contents.

## Key Concepts

### 1. No User Accounts

- No username/password authentication
- No email registration
- No personal data collection
- No user profiles
- Pure key-based access system

### 2. Access Keys

Replaces traditional user authentication:

```
Access Key Structure:
├── Key ID (unique identifier)
├── Public Key (RSA-2048)
├── Private Key (RSA-2048, Keychain-stored)
├── Creation Date
├── Expiration Date (optional)
└── Permissions (read, write, delete)
```

### 3. End-to-End Encryption

All files are encrypted twice:

#### Client-Side (RSA-2048)
```
Plaintext File
    ↓
Encrypt with Public Key
    ↓
Encrypted Blob
```

#### Server-Side (AES-256-GCM)
```
Encrypted Blob from Client
    ↓
Encrypt with Server Master Key
    ↓
Double-Encrypted Blob
    ↓
Store in S3
```

Decryption:
```
Double-Encrypted Blob (S3)
    ↓
Decrypt with Server Master Key
    ↓
Encrypted Blob (client-encrypted)
    ↓
Download to Client
    ↓
Decrypt with Private Key
    ↓
Plaintext File
```

## Client-Side Implementation

### CryptoService

Responsible for all cryptographic operations on device:

```swift
class CryptoService {
    func generateKeyPair() -> (public: String, private: String)
    func encryptData(_ data: Data, publicKey: String) -> Data
    func decryptData(_ encryptedData: Data, privateKey: String) -> Data
    func hashAccessKey(_ key: String) -> String
    func saveAccessKeyToKeychain(_ key: AccessKey) -> Void
    func retrieveAccessKeyFromKeychain(keyId: String) -> AccessKey
}
```

### Private Key Storage

Private keys stored securely in iOS Keychain:

- Protected by device biometrics (Face ID/Touch ID)
- Encrypted with device hardware key (Secure Enclave)
- Never exported in plaintext
- Deleted only by explicit user action

### StorageService

Manages file operations with encryption:

```swift
class StorageService {
    func generateNewAccessKey() -> (key: AccessKey, qrCode: String)
    func importAccessKeyFromQR(_ qrData: String) -> Void
    func uploadFile(data: Data, name: String) -> Void
    func downloadFile(_ file: CloudFile) -> Data
    func deleteFile(_ file: CloudFile) -> Void
}
```

## Server-Side Implementation

### What Server Processes

1. Receives encrypted blob from client
2. Validates access key hash (not actual key)
3. Applies server-side encryption (AES-256-GCM)
4. Stores encrypted blob in S3
5. Records metadata (no plain text data)
6. Returns encrypted file on download

### What Server CANNOT Do

- Decrypt files (doesn't have private key)
- Read file contents
- See file names
- Track user activity
- Access unencrypted metadata
- Monitor who accessed what
- Create access patterns

### Access Key Validation

Server only validates access key HASH:

```
Client sends: accessKeyHash (SHA256)
Server:
  1. Lookup accessKeyHash in database
  2. If found: Allow access
  3. If not found: Deny access
  4. Never stores or sees actual key
```

## Security Model

### Threat Model

#### Server Compromise

If server is compromised:
- Attacker gets encrypted files
- Attacker cannot decrypt files
- Private keys safely on client devices
- Attacker cannot access metadata

#### Network Interception

If network traffic is intercepted:
- All data is encrypted (TLS 1.3)
- Files are encrypted payload
- Private keys never transmitted

#### Device Loss

If device is stolen:
- Private key is in Keychain
- Keychain protected by device PIN/biometrics
- Attacker cannot extract key
- Old access key is compromised but can generate new one

#### Government Request

If government demands data:
- Server has only encrypted files
- No metadata about users
- No access logs
- No meaningful data to provide

### Cryptographic Standards

- **RSA**: 2048-bit keys
- **AES**: 256-bit symmetric encryption
- **GCM**: Authenticated encryption
- **SHA256**: Key hashing
- **TLS**: 1.3 minimum

## Data Flow

### Upload Flow

```
User selects file
    ↓
Read file into memory
    ↓
Encrypt with public key (RSA-2048)
    ↓
Create file metadata
    ↓
Send encrypted blob + metadata to server
    ↓
Server receives:
  - Encrypted file blob
  - accessKeyHash
  - fileName (plain text, not sensitive)
  - mimeType
    ↓
Server encrypts blob again (AES-256-GCM)
    ↓
Store in S3
    ↓
Store metadata in MongoDB
    ↓
Return fileId to client
```

### Download Flow

```
User requests file download
    ↓
Send request with accessKeyHash
    ↓
Server validates accessKeyHash
    ↓
Server retrieves file from S3
    ↓
Server decrypts server-side encryption
    ↓
Server sends encrypted blob to client
    ↓
Client receives encrypted blob
    ↓
Client decrypts with private key
    ↓
Client displays file
```

## Access Control

### Granular Permissions

Each access key can have specific permissions:

```
Permissions:
- read: Can download files
- write: Can upload new files
- delete: Can delete files
- share: Can generate new access keys
```

### Key Sharing

Share encrypted keys via QR code:

```
QR Code contains:
├── Key ID
├── Public Key (Base64)
└── Optional: Expiration date

Recipient scans QR
    ↓
App imports key into Keychain
    ↓
Recipient can now upload files
```

## Metadata Encryption

While file contents are encrypted, metadata is necessary for functionality:

### Stored As-Is (Cannot be encrypted)
- File ID (unique identifier)
- File size (needed for UI)
- MIME type (needed for file handling)
- Upload timestamp (needed for sorting)
- Expiration date (needed for cleanup)

### Server-Side Encrypted
- File name
- Description
- User custom metadata

## File Expiration

Automatic deletion after expiration:

```
File uploaded at: 2026-01-02 16:00 UTC
Expiration period: 90 days
Expiration date: 2026-04-02 16:00 UTC

Server automatically:
1. Check expiration daily
2. Delete expired files from S3
3. Delete metadata from database
4. No recovery possible after expiration
```

## Memory Protection

### Sensitive Data in RAM

All sensitive data is protected in memory:

```swift
var sensitiveData = "private_key_bytes"

// Use data...

// Securely wipe from memory
sensitiveData.withUnsafeMutableBytes { buffer in
    memset(buffer.baseAddress!, 0, buffer.count)
}
```

## Logging Policy

No sensitive logs:

- No file contents logged
- No file names logged
- No access patterns logged
- No user identity logged
- Only infrastructure metrics logged
- All logs encrypted at rest

## Backup Security

Backups are encrypted:

```
Database backup:
  ├── Encrypted with separate key
  ├── Stored offline
  ├── Periodic integrity checks
  └── Test recovery annually
```

## Key Rotation

### Client-Side Key Rotation

When user wants to rotate key:

```
1. Generate new RSA-2048 key pair
2. Store new private key in Keychain
3. Create new access key entry
4. Share new QR code
5. Users can revoke old key
```

### Server-Side Key Rotation

Server master key rotation (quarterly):

```
1. Generate new master key
2. Re-encrypt all files with new key
3. Delete old key
4. No user intervention needed
```

## Audit Trail

No user-specific audit trail:

```
Server logs (infrastructure only):
- API response times
- Server error counts
- S3 operation counts
- Database performance metrics
- TLS handshake statistics

Never logged:
- Who downloaded what
- File names
- File sizes (exact)
- Access times
- User locations
- Device information
```

## Compliance

### Privacy Standards

- GDPR compliant (no personal data collected)
- CCPA compliant (no data to request)
- HIPAA ready (end-to-end encryption)
- SOC2 audit ready (no user data to audit)

### Security Standards

- Uses NIST-approved algorithms
- RSA-2048 meets NIST guidelines through 2030
- AES-256 approved by NSA Suite B
- TLS 1.3 current standard

## Disaster Recovery

### Server Disaster

If entire server is lost:

```
1. Restore from encrypted backup
2. Files remain encrypted
3. Users can still decrypt with private key
4. No data loss to users
5. Service continuity in hours
```

### Key Loss Scenarios

#### Private Key Lost
- Generate new access key
- Old files become inaccessible
- Design feature (no backdoor)

#### Public Key Leaked
- Only encryption capability lost
- Cannot decrypt files
- Generate new key pair
- Revoke old public key

#### Server Master Key Lost
- Cannot happen (never exposed)
- Server doesn't know private keys
- Encrypted files remain safe

## Performance Implications

Encryption adds minimal overhead:

- RSA encryption: ~100ms per file
- AES encryption: ~1ms per MB
- Network is typically bottleneck
- Encryption CPU cost is acceptable

## Testing Security

Security testing checklist:

- [ ] Private key never leaves Keychain
- [ ] Server cannot decrypt files
- [ ] Access key hash validates properly
- [ ] Expired files are deleted
- [ ] TLS 1.3 is enforced
- [ ] No plaintext data in logs
- [ ] Metadata is encrypted server-side
- [ ] QR code import works correctly
- [ ] Device loss scenario tested
- [ ] Server compromise scenario tested

## Future Enhancements

- Hardware security key support
- Quantum-resistant algorithms
- Multi-factor key verification
- Distributed trust model
- Blockchain audit trail (optional)

## Questions and Support

For security concerns: security@totallynotacloud.local

For technical questions: See README.md and SERVER_SETUP.md
