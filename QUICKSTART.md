# Quick Start Guide

Get totallynotacloud running in 5 minutes!

## Prerequisites

- macOS 13.0+
- Xcode 15.0+ ([Download](https://apps.apple.com/app/xcode/id497799835))
- ~2 GB free disk space
- Git

## Step 1: Clone Repository

```bash
git clone https://github.com/notpwned/totallynotacloud.git
cd totallynotacloud
```

## Step 2: Create Xcode Projects

Full detailed instructions: [XCODE_SETUP.md](XCODE_SETUP.md)

### For iOS:

1. Open iOS folder in Xcode:
   ```bash
   xed iOS/
   ```

2. In Xcode: File > New > Project
   - Choose "App" template
   - Product Name: `totallynotacloud`
   - Team: (your team or leave empty)
   - Organization ID: `com.example`
   - Interface: SwiftUI
   - Life Cycle: SwiftUI App

3. Save in: `iOS/`

4. Add files to project:
   - Select project in navigator
   - Under "Build Phases" > "Compile Sources"
   - Add all .swift files from iOS/ folder

### For macOS:

1. Open macOS folder in Xcode:
   ```bash
   xed macOS/
   ```

2. In Xcode: File > New > Project
   - Choose "App" template
   - Product Name: `totallynotacloud`
   - Team: (your team or leave empty)
   - Organization ID: `com.example`
   - Platform: macOS
   - Interface: SwiftUI
   - Life Cycle: SwiftUI App

3. Save in: `macOS/`

4. Add files to project:
   - Select project in navigator
   - Under "Build Phases" > "Compile Sources"
   - Add all .swift files from macOS/ folder

## Step 3: Configure Build Settings

### iOS Settings

- Minimum Deployment: iOS 16.0
- Supported Platforms: iphoneos, iphonesimulator
- Valid Architectures: arm64, x86_64

### macOS Settings

- Minimum Deployment: macOS 13.0
- Supported Platforms: macosx
- Valid Architectures: arm64, x86_64

## Step 4: Run the App

### iOS

1. Select iPhone simulator
2. Press `Cmd + R` or click the Play button
3. App launches in simulator

### macOS

1. Select "My Mac" or "My Mac (Designed for iPad)"
2. Press `Cmd + R` or click the Play button
3. App launches on your Mac

## Step 5: Test the App

### Login

- **Email**: test@example.com
- **Password**: password123

Or create a new account (mock).

### Explore Features

**iOS:**
- Tap on "Files" tab to see file list
- Tap on "Storage" to view usage
- Tap on "Profile" to see user info
- Use "+" button to create folders (mock)
- Long-press files to delete

**macOS:**
- Click items in sidebar to navigate
- Drag files onto the window to "upload" them
- Use menu to create folders
- Right-click files to delete

## Troubleshooting

### "Build failed" error

**Solution:**
```bash
# Clean build cache
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Clean project
Cmd + Shift + K in Xcode
```

### "Missing file" error

**Solution:**
1. In Xcode, select project
2. Select target
3. Go to "Build Phases"
4. Expand "Compile Sources"
5. Click "+" and add missing .swift files

### Simulator won't launch

**Solution:**
```bash
# List simulators
xcrun simctl list

# Reset simulator
xcrun simctl erase all
```

### App crashes on startup

**Solution:**
1. Check that all Models are imported
2. Check that all Services are imported
3. Verify AppColors.swift is included
4. Check console for error messages

## Next Steps

1. **Understand the Architecture**
   - Read [DEVELOPMENT.md](DEVELOPMENT.md)
   - Review Models and Services
   - Check Views and UI patterns

2. **Integrate Real Backend**
   - See [API_SPEC.md](API_SPEC.md)
   - Update AuthService for real API
   - Update StorageService for real uploads
   - Add Keychain for secure storage

3. **Enhance Features**
   - Add DocumentPicker (iOS)
   - Add Drag & Drop (iOS)
   - Add previews (macOS)
   - Add keyboard shortcuts (macOS)

4. **Deploy**
   - Create App Store accounts
   - Setup signing and provisioning
   - Submit apps to App Store

## Resources

- [Project Summary](PROJECT_SUMMARY.md) - Complete project overview
- [Development Guide](DEVELOPMENT.md) - Architecture and patterns
- [API Specification](API_SPEC.md) - Backend integration guide
- [Roadmap](ROADMAP.md) - Feature roadmap for 2026
- [Xcode Setup](XCODE_SETUP.md) - Detailed Xcode configuration

## Common Commands

```bash
# Build from command line
xcodebuild -scheme totallynotacloud -configuration Debug

# Build for iOS Simulator
xcodebuild -scheme totallynotacloud -destination 'platform=iOS Simulator,name=iPhone 15'

# Build for macOS
xcodebuild -scheme totallynotacloud -destination 'platform=macOS'

# Run tests
xcodebuild test -scheme totallynotacloud
```

## Getting Help

1. Check [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) for architecture details
2. Read [DEVELOPMENT.md](DEVELOPMENT.md) for setup help
3. Review [XCODE_SETUP.md](XCODE_SETUP.md) for project configuration
4. Open a GitHub issue for bugs or features

## What's Next?

Your iOS and macOS apps are now running! 

Now it's time to:

1. Set up your backend server (see API_SPEC.md)
2. Replace mock authentication with real API
3. Add file upload functionality
4. Deploy to App Store

Good luck! 🚀
