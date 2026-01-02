# totallynotacloud

Private. Encrypted. Yours.

Zero-knowledge cloud storage with client-side encryption, no user accounts, and complete privacy control. Every file is encrypted before reaching the server. Only you can decrypt your files.

## Features

- Zero-Knowledge Architecture: Server cannot decrypt files
- No User Accounts: Generate access keys instead of passwords
- Client-Side Encryption: Files encrypted before upload with RSA-2048
- No Data Collection: No metadata, no tracking, no logs
- Access Control: Share encrypted keys via QR code
- Memory Protection: Sensitive data encrypted in RAM
- Self-Destruct: Files expire automatically (default 90 days)
- Minimal UI: NothingOS-inspired black and white design
- Open Source: Full transparency on security model

## Platform Support

### iOS
- Minimum iOS 16.0
- Native SwiftUI interface
- Secure Keychain storage
- QR code generation and scanning

### macOS
- Minimum macOS 13.0
- Desktop-optimized interface
- Drag and drop file management
- Native Keychain integration

## Installation

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- iOS device or simulator

### Setup

1. Clone repository

```bash
git clone https://github.com/notpwned/totallynotacloud.git
cd totallynotacloud
```

2. Open in Xcode

```bash
xed iOS/
```

3. Create new iOS project in Xcode and add Swift files

4. Build and run on simulator or device

## Server Setup

See [SERVER_SETUP.md](SERVER_SETUP.md) for complete server deployment guide.

Key points:
- Zero-knowledge encryption architecture
- All files encrypted server-side with AES-256-GCM
- Private keys never transmitted to server
- Optional MinIO or S3-compatible storage
- MongoDB for encrypted metadata
- Automatic file expiration

## Architecture

### Client Flow

1. Generate access key (RSA-2048 key pair)
2. Save private key in Keychain
3. Share public key via QR code
4. File encrypted locally before upload
5. Upload encrypted blob to server
6. Server stores encrypted data only
7. Download receives encrypted file
8. Client decrypts with private key

### Server Flow

1. Receive encrypted file from client
2. Encrypt blob server-side (AES-256-GCM)
3. Store in S3-compatible storage
4. Store metadata in database (no plain text)
5. Validate access key hash on download
6. Return encrypted blob to client
7. Delete after expiration (90 days default)

## Security Model

### What Server Sees

- Access key hash (not the actual key)
- File size (encrypted)
- MIME type (encrypted)
- Upload timestamp (encrypted)
- Expiration date

### What Server Does NOT See

- File contents
- File names
- User identity
- Access patterns
- Private keys
- Unencrypted metadata

### Encryption

- Client: RSA-2048 public key encryption
- Server: AES-256-GCM symmetric encryption
- Transport: TLS 1.3
- Storage: At-rest encryption in database and S3

## Project Structure

```
iOS/
  Models/
    CloudFile.swift
  Services/
    CryptoService.swift
    StorageService.swift
  Views/
    AuthView.swift
    FilesView.swift
    etc.
  App/
    AppColors.swift
    totallynotacloudApp.swift

macOS/
  Views/
    AuthView.swift
    ContentView.swift
  App/
    AppColors.swift

SERVER_SETUP.md
README.md
```

## Key Generation

On first launch, the app generates an RSA-2048 key pair:

- Public Key: Shared with others to allow file uploads
- Private Key: Stored securely in Keychain, never leaves device

Both keys are needed for full encryption/decryption workflow.

## Sharing Files

1. Generate access key (creates public/private keypair)
2. Display QR code with key ID and public key
3. Share QR code with recipient
4. Recipient scans to grant access
5. Upload encrypted file
6. Share file ID (optional, public) with recipient

## File Expiration

Files automatically deleted after configurable period:

- Default: 90 days
- Maximum: 1 year
- Minimum: 1 day
- Server automatically removes at expiration
- No manual intervention needed

## Privacy Guarantees

- No email required
- No username/password
- No IP logging
- No access history
- No download tracking
- No device fingerprinting
- No analytics
- No cookies
- No persistent user data

## API Endpoints

All endpoints require `x-access-key-hash` header.

### Upload File

```
POST /api/upload
Body: {
  fileId: string,
  fileName: string (encrypted),
  encryptedData: base64-string,
  accessKeyHash: string,
  mimeType: string
}
Response: { fileId, success }
```

### Download File

```
GET /api/download/:fileId
Header: x-access-key-hash
Response: Encrypted file blob
```

### List Files

```
GET /api/files
Header: x-access-key-hash
Response: { files: [ { fileId, size, mimeType, uploadedAt } ] }
```

### Delete File

```
DELETE /api/files/:fileId
Header: x-access-key-hash
Response: { success }
```

## Environment Variables (Client)

```bash
API_BASE_URL=https://api.totallynotacloud.local
RSA_KEY_SIZE=2048
DEFAULT_EXPIRATION_DAYS=90
```

## Environment Variables (Server)

See SERVER_SETUP.md for complete list.

## Performance

- RSA encryption: ~100ms per file
- Upload speed: Limited by network
- Download speed: Limited by network
- File size limit: 10GB (configurable)
- Concurrent uploads: Unlimited

## Browser Support

- Not a web application
- iOS and macOS native apps only
- Better security guarantees than web
- No JavaScript vulnerabilities
- Direct access to OS security features

## Development

### Building iOS

```bash
xcodebuild -scheme totallynotacloud -configuration Debug
```

### Building macOS

```bash
xcodebuild -scheme totallynotacloud -configuration Debug -destination 'platform=macOS'
```

### Testing

```bash
xcodebuild test -scheme totallynotacloud
```

## Documentation

- SERVER_SETUP.md - Complete server deployment guide
- COMPONENTS.md - Detailed component documentation
- QUICKSTART.md - Getting started guide
- API_SPEC.md - API specification
- DEVELOPMENT.md - Development guide

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Submit pull request

## License

MIT License - See LICENSE file

## Security

For security vulnerabilities, contact: security@totallynotacloud.local

Do not create public GitHub issues for security problems.

## Roadmap

- Android support
- Web interface (client-side encryption only)
- Desktop applications (Windows, Linux)
- File versioning
- Collaborative encryption
- Hardware security key support

## FAQ

Q: Can the server see my files?
A: No. Files are encrypted on your device before upload. Server only stores encrypted blobs.

Q: Can you help me recover my files?
A: Only if you have your private key. No backdoor exists.

Q: What if I lose my device?
A: Generate a new access key. Old files become inaccessible (by design).

Q: Can you see who downloaded my files?
A: No. Server does not log access patterns or user identity.

Q: Is this open source?
A: Yes. Full source code on GitHub. Audit welcome.

Q: How is this different from other cloud storage?
A: Zero-knowledge architecture means server literally cannot see your data.

## Status

Active Development

First Release: January 2026
