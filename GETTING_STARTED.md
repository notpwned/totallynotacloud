# Getting Started

## Installation

### iOS

1. Clone repository
```bash
git clone https://github.com/notpwned/totallynotacloud.git
cd totallynotacloud
```

2. Open iOS folder in Xcode
```bash
xed iOS/
```

3. Create new project in Xcode
- File > New > Project
- Select "App" template
- Product Name: totallynotacloud
- Interface: SwiftUI
- Life Cycle: SwiftUI App
- Organization ID: com.example
- Save in iOS folder

4. Add Swift files to project
- Select project in navigator
- Select target
- Build Phases > Compile Sources
- Add all .swift files from iOS folder

5. Build and run
- Select iPhone simulator
- Press Cmd+R

### macOS

Same process as iOS but:
- Open macOS folder in Xcode
- Create macOS app project
- Add files from macOS folder
- Select "My Mac" as destination

## First Launch

### Generate Access Key

1. App opens to Auth screen
2. Tap "Generate Access Key"
3. App generates RSA-2048 key pair
4. App displays key ID and private key
5. Save private key securely

The private key is:
- Stored in Keychain
- Protected by device biometrics
- Never transmitted to server
- Essential for decrypting files

### Import Existing Key

To use existing key:

1. Tap "Scan Access Key"
2. Scan QR code containing key
3. App imports key into Keychain
4. Ready to use

## Using the App

### Files Tab

Manage your files:

- View file list
- Create folders
- Delete files
- See upload progress

### Storage Tab

View storage statistics:

- Total file count
- Folder count
- Total storage used
- Encryption status

### Settings Tab

- Export your private key
- View security info
- Check encryption details

## Sharing Files

### Generate QR Code

1. Go to Settings tab
2. Tap "Export Key"
3. Tap "Show QR Code"
4. Share QR code with recipient

Recipient can:
- Scan QR to import your public key
- Upload encrypted files to your storage

### File ID Sharing

After upload:

1. File gets unique ID (shown in Files tab)
2. Share file ID with recipient
3. Recipient needs your public key to access
4. Send QR code separately

## Server Setup

To use with backend server:

See [SERVER_SETUP.md](SERVER_SETUP.md) for:
- Complete server deployment
- Database setup
- S3 configuration
- Security hardening

## Architecture Overview

See [PRIVACY_ARCHITECTURE.md](PRIVACY_ARCHITECTURE.md) for:
- How encryption works
- Zero-knowledge design
- Security model
- Threat protection

## Security Best Practices

1. **Backup your private key**
   - Store in secure location
   - Not cloud services
   - Consider hardware wallet

2. **Never share private key**
   - Keep in Keychain
   - Generate new keys to revoke access

3. **Use strong device PIN**
   - Keychain is protected by device security
   - Biometrics optional but recommended

4. **Review shared keys**
   - In Settings, see all imported keys
   - Delete keys you no longer trust

5. **Monitor file expiration**
   - Files auto-delete after 90 days (default)
   - Set custom expiration per file

## Troubleshooting

### App crashes on launch

- Check all .swift files are added to target
- Verify AppColors.swift is included
- Check deployment target is iOS 16+

### Key generation fails

- Ensure adequate storage space
- Try generating key again
- Check iOS version

### Upload fails

- Verify internet connection
- Check server is running
- Verify API URL in code

### Private key not found

- Check Keychain access
- Generate new key
- Reimport from QR if available

## API Configuration

To use custom server:

1. Update API URL in StorageService.swift
```swift
private let apiBaseURL = "https://your-server.com"
```

2. Deploy server following SERVER_SETUP.md

3. Rebuild app

## Development

### Building from command line

```bash
xcodebuild -scheme totallynotacloud -configuration Debug
```

### Running tests

```bash
xcodebuild test -scheme totallynotacloud
```

## File Structure

```
iOS/
  Models/
    CloudFile.swift          (File model with encryption hash)
  Services/
    CryptoService.swift      (RSA encryption/decryption)
    StorageService.swift     (File management)
  Views/
    AuthView.swift           (Key generation/import)
    FilesView.swift          (File listing)
    StorageView.swift        (Storage stats)
    MainTabView.swift        (Tab navigation)
  App/
    AppColors.swift          (NothingOS-inspired theme)
    totallynotacloudApp.swift (App entry point)
```

## Key Files

- **README.md** - Project overview
- **SERVER_SETUP.md** - Backend deployment
- **PRIVACY_ARCHITECTURE.md** - Security details
- **GETTING_STARTED.md** - This file

## Next Steps

1. Install and run iOS app
2. Generate your first access key
3. Read PRIVACY_ARCHITECTURE.md
4. Deploy server (optional)
5. Upload encrypted files

## Support

For issues:
- Check GitHub issues
- Read documentation
- Check app console for errors

For security:
- Email security@totallynotacloud.local
- Do not create public issues

For questions:
- Review documentation
- Check code comments
- Check example usage in Views

## License

MIT License

Free to use, modify, and distribute.

See LICENSE file for details.
