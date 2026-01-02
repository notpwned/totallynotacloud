# totallynotacloud

Private. Encrypted. Yours.

Zero-knowledge encrypted file exchange. No accounts, no tracking, complete privacy. Files are encrypted on your device before upload. Server cannot decrypt anything.

## Features

- Zero-Knowledge Architecture: Server cannot decrypt files
- File Exchange: Share encrypted files via pseudo-links
- No Accounts: Generate access keys instead of passwords
- Client-Side Encryption: RSA-2048 encryption before upload
- Keychain Storage: Private keys secured in OS Keychain
- Auto-Expiration: Files expire automatically
- Minimal UI: Clean black and white design
- Open Source: Full transparency

## Platform Support

- iOS 16.0+
- macOS 13.0+ (coming soon)

## Installation

1. Clone repository

```bash
git clone https://github.com/notpwned/totallynotacloud.git
cd totallynotacloud
```

2. Open iOS project in Xcode

```bash
xed iOS/
```

3. Build and run on simulator or device

## First Launch

1. Open app
2. Tap "Generate Access Key"
3. Save your Key ID and Private Key securely
4. Tap "Continue" to authenticate
5. Start uploading files

## How It Works

### File Upload

1. Select file to share
2. File encrypted with your public key on device
3. Upload encrypted blob to server
4. Receive pseudo-link (tcd://exchange/[fileId])
5. Share link with others

### File Download

1. Receive pseudo-link from sender
2. Download encrypted file from server
3. Decrypt using your private key
4. Save decrypted file

## Architecture

### Client-Side

- RSA-2048 key generation
- File encryption before upload
- Private key stored in Keychain
- No plain text data in memory

### Server-Side

- AES-256-GCM encryption on server
- No user accounts or sessions
- Access control via key hashes
- Automatic file expiration
- S3-compatible storage

## Security

### What Server Sees

- Access key hash (not the actual key)
- Encrypted file blob
- File size and MIME type
- Upload and expiration timestamps

### What Server Does NOT See

- File contents
- Private keys
- User identity
- Download history
- Access patterns

## Project Structure

```
iOS/
  Models/
    AccessKey.swift
    ExchangeFile.swift
    UploadProgress.swift
  Services/
    CryptoService.swift
    KeychainService.swift
    StorageService.swift
  Views/
    AuthView.swift
    FilesView.swift
    MainTabView.swift
    SettingsView.swift
  App/
    AppColors.swift
    totallynotacloudApp.swift
```

## Server Setup

See SERVER_SETUP.md for complete server deployment guide.

### Requirements

- Node.js 18+
- MongoDB 6+
- MinIO or AWS S3
- TLS 1.3+ support

### Quick Start

```bash
cd server
npm install
cp .env.example .env
# Edit .env with your settings
npm start
```

## API

All endpoints require `x-access-key-hash` header.

### POST /api/upload

```json
{
  "fileName": "encrypted-string",
  "encryptedData": "base64-string",
  "mimeType": "application/octet-stream",
  "expiresIn": 604800
}
```

Response:

```json
{
  "fileId": "uuid",
  "expiresAt": "2026-01-09T20:40:00Z"
}
```

### GET /api/download/:fileId

Returns encrypted file blob.

### GET /api/files

Returns list of user's uploaded files.

### DELETE /api/files/:fileId

Deletes file from server.

## Privacy Guarantees

- No email or username required
- No password database
- No session tokens
- No IP logging
- No device fingerprinting
- No analytics
- No cookies
- No persistent user identification

## Performance

- Encryption time: 50-200ms per file (varies by size)
- Upload speed: Network limited
- File size limit: 10GB (configurable)

## Development

### Building

```bash
xcodebuild -scheme totallynotacloud -configuration Debug
```

### Testing

```bash
xcodebuild test -scheme totallynotacloud
```

## Documentation

- SERVER_SETUP.md - Server deployment and configuration
- PRIVACY_ARCHITECTURE.md - Detailed security model
- GETTING_STARTED.md - Step-by-step guide

## Contributing

Fork, branch, commit, push, pull request.

## License

MIT License

## Security

For security issues: security@totallynotacloud.local

Do not create public GitHub issues for vulnerabilities.

## FAQ

Q: Can the server read my files?
A: No. Files encrypted on your device before upload.

Q: What if I lose my access key?
A: Generate a new one. Old files become inaccessible (by design).

Q: Can you recover my deleted files?
A: No. Deleted files are gone permanently.

Q: Why no web version?
A: Native apps provide better security guarantees than web browsers.

## Status

Active development - January 2026
